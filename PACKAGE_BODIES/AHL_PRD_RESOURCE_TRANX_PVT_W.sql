--------------------------------------------------------
--  DDL for Package Body AHL_PRD_RESOURCE_TRANX_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_RESOURCE_TRANX_PVT_W" as
  /* $Header: AHLWTRSB.pls 120.2 2006/01/19 16:48 sikumar noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_prd_resource_tranx_pvt.prd_resource_txns_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_DATE_TABLE
    , a28 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).workorder_id := a0(indx);
          t(ddindx).workorder_operation_id := a1(indx);
          t(ddindx).operation_resource_id := a2(indx);
          t(ddindx).organization_id := a3(indx);
          t(ddindx).operation_sequence_num := a4(indx);
          t(ddindx).resource_sequence_num := a5(indx);
          t(ddindx).resource_name := a6(indx);
          t(ddindx).resource_id := a7(indx);
          t(ddindx).employee_num := a8(indx);
          t(ddindx).employee_name := a9(indx);
          t(ddindx).person_id := a10(indx);
          t(ddindx).department_code := a11(indx);
          t(ddindx).department_id := a12(indx);
          t(ddindx).serial_number := a13(indx);
          t(ddindx).instance_id := a14(indx);
          t(ddindx).qty := a15(indx);
          t(ddindx).uom_code := a16(indx);
          t(ddindx).uom_meaning := a17(indx);
          t(ddindx).activity_meaning := a18(indx);
          t(ddindx).activity_id := a19(indx);
          t(ddindx).reason_id := a20(indx);
          t(ddindx).reason := a21(indx);
          t(ddindx).reference := a22(indx);
          t(ddindx).dml_operation := a23(indx);
          t(ddindx).resource_type_code := a24(indx);
          t(ddindx).resource_type_name := a25(indx);
          t(ddindx).department_name := a26(indx);
          t(ddindx).transaction_date := a27(indx);
          t(ddindx).end_date := a28(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ahl_prd_resource_tranx_pvt.prd_resource_txns_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).workorder_id;
          a1(indx) := t(ddindx).workorder_operation_id;
          a2(indx) := t(ddindx).operation_resource_id;
          a3(indx) := t(ddindx).organization_id;
          a4(indx) := t(ddindx).operation_sequence_num;
          a5(indx) := t(ddindx).resource_sequence_num;
          a6(indx) := t(ddindx).resource_name;
          a7(indx) := t(ddindx).resource_id;
          a8(indx) := t(ddindx).employee_num;
          a9(indx) := t(ddindx).employee_name;
          a10(indx) := t(ddindx).person_id;
          a11(indx) := t(ddindx).department_code;
          a12(indx) := t(ddindx).department_id;
          a13(indx) := t(ddindx).serial_number;
          a14(indx) := t(ddindx).instance_id;
          a15(indx) := t(ddindx).qty;
          a16(indx) := t(ddindx).uom_code;
          a17(indx) := t(ddindx).uom_meaning;
          a18(indx) := t(ddindx).activity_meaning;
          a19(indx) := t(ddindx).activity_id;
          a20(indx) := t(ddindx).reason_id;
          a21(indx) := t(ddindx).reason;
          a22(indx) := t(ddindx).reference;
          a23(indx) := t(ddindx).dml_operation;
          a24(indx) := t(ddindx).resource_type_code;
          a25(indx) := t(ddindx).resource_type_name;
          a26(indx) := t(ddindx).department_name;
          a27(indx) := t(ddindx).transaction_date;
          a28(indx) := t(ddindx).end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy ahl_prd_resource_tranx_pvt.prd_myworkorder_txns_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).workorder_id := a0(indx);
          t(ddindx).workorder_operation_id := a1(indx);
          t(ddindx).assignment_id := a2(indx);
          t(ddindx).resource_sequence := a3(indx);
          t(ddindx).operation_sequence := a4(indx);
          t(ddindx).employee_id := a5(indx);
          t(ddindx).total_transacted_hours := a6(indx);
          t(ddindx).transacted_hours := a7(indx);
          t(ddindx).dml_operation := a8(indx);
          t(ddindx).object_version_number := a9(indx);
          t(ddindx).op_object_version_number := a10(indx);
          t(ddindx).operation_complete := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ahl_prd_resource_tranx_pvt.prd_myworkorder_txns_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).workorder_id;
          a1(indx) := t(ddindx).workorder_operation_id;
          a2(indx) := t(ddindx).assignment_id;
          a3(indx) := t(ddindx).resource_sequence;
          a4(indx) := t(ddindx).operation_sequence;
          a5(indx) := t(ddindx).employee_id;
          a6(indx) := t(ddindx).total_transacted_hours;
          a7(indx) := t(ddindx).transacted_hours;
          a8(indx) := t(ddindx).dml_operation;
          a9(indx) := t(ddindx).object_version_number;
          a10(indx) := t(ddindx).op_object_version_number;
          a11(indx) := t(ddindx).operation_complete;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure process_resource_txns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a10 in out nocopy JTF_NUMBER_TABLE
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 in out nocopy JTF_NUMBER_TABLE
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 in out nocopy JTF_NUMBER_TABLE
    , p9_a15 in out nocopy JTF_NUMBER_TABLE
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a19 in out nocopy JTF_NUMBER_TABLE
    , p9_a20 in out nocopy JTF_NUMBER_TABLE
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a27 in out nocopy JTF_DATE_TABLE
    , p9_a28 in out nocopy JTF_DATE_TABLE
  )

  as
    ddp_x_prd_resrc_txn_tbl ahl_prd_resource_tranx_pvt.prd_resource_txns_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ahl_prd_resource_tranx_pvt_w.rosetta_table_copy_in_p1(ddp_x_prd_resrc_txn_tbl, p9_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_resource_tranx_pvt.process_resource_txns(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_prd_resrc_txn_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_prd_resource_tranx_pvt_w.rosetta_table_copy_out_p1(ddp_x_prd_resrc_txn_tbl, p9_a0
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
      );
  end;

  procedure process_myworkorder_txns(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_default  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_NUMBER_TABLE
    , p9_a5 in out nocopy JTF_NUMBER_TABLE
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 in out nocopy JTF_NUMBER_TABLE
    , p9_a10 in out nocopy JTF_NUMBER_TABLE
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_x_prd_myworkorder_txn_tbl ahl_prd_resource_tranx_pvt.prd_myworkorder_txns_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ahl_prd_resource_tranx_pvt_w.rosetta_table_copy_in_p3(ddp_x_prd_myworkorder_txn_tbl, p9_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_resource_tranx_pvt.process_myworkorder_txns(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_default,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_x_prd_myworkorder_txn_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    ahl_prd_resource_tranx_pvt_w.rosetta_table_copy_out_p3(ddp_x_prd_myworkorder_txn_tbl, p9_a0
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
      );
  end;

  procedure get_resource_txn_defaults(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_employee_id  NUMBER
    , p_workorder_id  NUMBER
    , p_operation_seq_num  NUMBER
    , p_function_name  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a7 out nocopy JTF_NUMBER_TABLE
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a10 out nocopy JTF_NUMBER_TABLE
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 out nocopy JTF_NUMBER_TABLE
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a19 out nocopy JTF_NUMBER_TABLE
    , p10_a20 out nocopy JTF_NUMBER_TABLE
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a27 out nocopy JTF_DATE_TABLE
    , p10_a28 out nocopy JTF_DATE_TABLE
  )

  as
    ddx_resource_txn_tbl ahl_prd_resource_tranx_pvt.prd_resource_txns_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    ahl_prd_resource_tranx_pvt.get_resource_txn_defaults(p_api_version,
      p_init_msg_list,
      p_module_type,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_employee_id,
      p_workorder_id,
      p_operation_seq_num,
      p_function_name,
      ddx_resource_txn_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    ahl_prd_resource_tranx_pvt_w.rosetta_table_copy_out_p1(ddx_resource_txn_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      );
  end;

end ahl_prd_resource_tranx_pvt_w;

/
