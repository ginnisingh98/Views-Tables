--------------------------------------------------------
--  DDL for Package Body EAM_PROCESS_WO_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PROCESS_WO_PUB_W" as
  /* $Header: EAMVWORB.pls 120.2.12010000.3 2012/06/27 13:27:03 rsandepo ship $ */
  procedure rosetta_table_copy_in_p25(t out nocopy eam_process_wo_pub.eam_wo_relations_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).batch_id := a0(indx);
          t(ddindx).wo_relationship_id := a1(indx);
          t(ddindx).parent_object_id := a2(indx);
          t(ddindx).parent_object_type_id := a3(indx);
          t(ddindx).parent_header_id := a4(indx);
          t(ddindx).child_object_id := a5(indx);
          t(ddindx).child_object_type_id := a6(indx);
          t(ddindx).child_header_id := a7(indx);
          t(ddindx).parent_relationship_type := a8(indx);
          t(ddindx).relationship_status := a9(indx);
          t(ddindx).top_level_object_id := a10(indx);
          t(ddindx).top_level_object_type_id := a11(indx);
          t(ddindx).top_level_header_id := a12(indx);
          t(ddindx).adjust_parent := a13(indx);
          t(ddindx).return_status := a14(indx);
          t(ddindx).transaction_type := a15(indx);
          t(ddindx).row_id := a16(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p25;
  procedure rosetta_table_copy_out_p25(t eam_process_wo_pub.eam_wo_relations_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
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
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).batch_id;
          a1(indx) := t(ddindx).wo_relationship_id;
          a2(indx) := t(ddindx).parent_object_id;
          a3(indx) := t(ddindx).parent_object_type_id;
          a4(indx) := t(ddindx).parent_header_id;
          a5(indx) := t(ddindx).child_object_id;
          a6(indx) := t(ddindx).child_object_type_id;
          a7(indx) := t(ddindx).child_header_id;
          a8(indx) := t(ddindx).parent_relationship_type;
          a9(indx) := t(ddindx).relationship_status;
          a10(indx) := t(ddindx).top_level_object_id;
          a11(indx) := t(ddindx).top_level_object_type_id;
          a12(indx) := t(ddindx).top_level_header_id;
          a13(indx) := t(ddindx).adjust_parent;
          a14(indx) := t(ddindx).return_status;
          a15(indx) := t(ddindx).transaction_type;
          a16(indx) := t(ddindx).row_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p25;

  procedure rosetta_table_copy_in_p26(t out nocopy eam_process_wo_pub.header_id_tbl_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t eam_process_wo_pub.header_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure rosetta_table_copy_in_p27(t out nocopy eam_process_wo_pub.eam_wo_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_DATE_TABLE
    , a58 JTF_DATE_TABLE
    , a59 JTF_DATE_TABLE
    , a60 JTF_DATE_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_DATE_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_200
    , a80 JTF_VARCHAR2_TABLE_200
    , a81 JTF_VARCHAR2_TABLE_200
    , a82 JTF_VARCHAR2_TABLE_200
    , a83 JTF_VARCHAR2_TABLE_200
    , a84 JTF_VARCHAR2_TABLE_200
    , a85 JTF_VARCHAR2_TABLE_200
    , a86 JTF_VARCHAR2_TABLE_200
    , a87 JTF_VARCHAR2_TABLE_200
    , a88 JTF_VARCHAR2_TABLE_200
    , a89 JTF_VARCHAR2_TABLE_200
    , a90 JTF_VARCHAR2_TABLE_200
    , a91 JTF_VARCHAR2_TABLE_200
    , a92 JTF_VARCHAR2_TABLE_200
    , a93 JTF_VARCHAR2_TABLE_200
    , a94 JTF_VARCHAR2_TABLE_100
    , a95 JTF_VARCHAR2_TABLE_100
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_DATE_TABLE
    , a98 JTF_DATE_TABLE
    , a99 JTF_NUMBER_TABLE
    , a100 JTF_NUMBER_TABLE
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_NUMBER_TABLE
    , a103 JTF_NUMBER_TABLE
    , a104 JTF_NUMBER_TABLE
    , a105 JTF_VARCHAR2_TABLE_100
    , a106 JTF_VARCHAR2_TABLE_100
    , a107 JTF_VARCHAR2_TABLE_100
    , a108 JTF_NUMBER_TABLE
    , a109 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_name := a3(indx);
          t(ddindx).wip_entity_id := a4(indx);
          t(ddindx).organization_id := a5(indx);
          t(ddindx).description := a6(indx);
          t(ddindx).asset_number := a7(indx);
          t(ddindx).asset_group_id := a8(indx);
          t(ddindx).rebuild_item_id := a9(indx);
          t(ddindx).rebuild_serial_number := a10(indx);
          t(ddindx).maintenance_object_id := a11(indx);
          t(ddindx).maintenance_object_type := a12(indx);
          t(ddindx).maintenance_object_source := a13(indx);
          t(ddindx).eam_linear_location_id := a14(indx);
          t(ddindx).class_code := a15(indx);
          t(ddindx).asset_activity_id := a16(indx);
          t(ddindx).activity_type := a17(indx);
          t(ddindx).activity_cause := a18(indx);
          t(ddindx).activity_source := a19(indx);
          t(ddindx).work_order_type := a20(indx);
          t(ddindx).status_type := a21(indx);
          t(ddindx).job_quantity := a22(indx);
          t(ddindx).date_released := a23(indx);
          t(ddindx).owning_department := a24(indx);
          t(ddindx).priority := a25(indx);
          t(ddindx).requested_start_date := a26(indx);
          t(ddindx).due_date := a27(indx);
          t(ddindx).shutdown_type := a28(indx);
          t(ddindx).firm_planned_flag := a29(indx);
          t(ddindx).notification_required := a30(indx);
          t(ddindx).tagout_required := a31(indx);
          t(ddindx).plan_maintenance := a32(indx);
          t(ddindx).project_id := a33(indx);
          t(ddindx).task_id := a34(indx);
          t(ddindx).end_item_unit_number := a35(indx);
          t(ddindx).schedule_group_id := a36(indx);
          t(ddindx).bom_revision_date := a37(indx);
          t(ddindx).routing_revision_date := a38(indx);
          t(ddindx).alternate_routing_designator := a39(indx);
          t(ddindx).alternate_bom_designator := a40(indx);
          t(ddindx).routing_revision := a41(indx);
          t(ddindx).bom_revision := a42(indx);
          t(ddindx).parent_wip_entity_id := a43(indx);
          t(ddindx).manual_rebuild_flag := a44(indx);
          t(ddindx).pm_schedule_id := a45(indx);
          t(ddindx).wip_supply_type := a46(indx);
          t(ddindx).material_account := a47(indx);
          t(ddindx).material_overhead_account := a48(indx);
          t(ddindx).resource_account := a49(indx);
          t(ddindx).outside_processing_account := a50(indx);
          t(ddindx).material_variance_account := a51(indx);
          t(ddindx).resource_variance_account := a52(indx);
          t(ddindx).outside_proc_variance_account := a53(indx);
          t(ddindx).std_cost_adjustment_account := a54(indx);
          t(ddindx).overhead_account := a55(indx);
          t(ddindx).overhead_variance_account := a56(indx);
          t(ddindx).scheduled_start_date := a57(indx);
          t(ddindx).scheduled_completion_date := a58(indx);
          t(ddindx).pm_suggested_start_date := a59(indx);
          t(ddindx).pm_suggested_end_date := a60(indx);
          t(ddindx).pm_base_meter_reading := a61(indx);
          t(ddindx).pm_base_meter := a62(indx);
          t(ddindx).common_bom_sequence_id := a63(indx);
          t(ddindx).common_routing_sequence_id := a64(indx);
          t(ddindx).po_creation_time := a65(indx);
          t(ddindx).gen_object_id := a66(indx);
          t(ddindx).user_defined_status_id := a67(indx);
          t(ddindx).pending_flag := a68(indx);
          t(ddindx).material_shortage_check_date := a69(indx);
          t(ddindx).material_shortage_flag := a70(indx);
          t(ddindx).workflow_type := a71(indx);
          t(ddindx).warranty_claim_status := a72(indx);
          t(ddindx).cycle_id := a73(indx);
          t(ddindx).seq_id := a74(indx);
          t(ddindx).ds_scheduled_flag := a75(indx);
          t(ddindx).warranty_active := a76(indx);
          t(ddindx).assignment_complete := a77(indx);
          t(ddindx).attribute_category := a78(indx);
          t(ddindx).attribute1 := a79(indx);
          t(ddindx).attribute2 := a80(indx);
          t(ddindx).attribute3 := a81(indx);
          t(ddindx).attribute4 := a82(indx);
          t(ddindx).attribute5 := a83(indx);
          t(ddindx).attribute6 := a84(indx);
          t(ddindx).attribute7 := a85(indx);
          t(ddindx).attribute8 := a86(indx);
          t(ddindx).attribute9 := a87(indx);
          t(ddindx).attribute10 := a88(indx);
          t(ddindx).attribute11 := a89(indx);
          t(ddindx).attribute12 := a90(indx);
          t(ddindx).attribute13 := a91(indx);
          t(ddindx).attribute14 := a92(indx);
          t(ddindx).attribute15 := a93(indx);
          t(ddindx).material_issue_by_mo := a94(indx);
          t(ddindx).issue_zero_cost_flag := a95(indx);
          t(ddindx).report_type := a96(indx);
          t(ddindx).actual_close_date := a97(indx);
          t(ddindx).submission_date := a98(indx);
          t(ddindx).user_id := a99(indx);
          t(ddindx).responsibility_id := a100(indx);
          t(ddindx).request_id := a101(indx);
          t(ddindx).program_id := a102(indx);
          t(ddindx).program_application_id := a103(indx);
          t(ddindx).source_line_id := a104(indx);
          t(ddindx).source_code := a105(indx);
          t(ddindx).validate_structure := a106(indx);
          t(ddindx).return_status := a107(indx);
          t(ddindx).transaction_type := a108(indx);
          t(ddindx).failure_code_required := a109(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p27;
  procedure rosetta_table_copy_out_p27(t eam_process_wo_pub.eam_wo_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_DATE_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_DATE_TABLE
    , a58 out nocopy JTF_DATE_TABLE
    , a59 out nocopy JTF_DATE_TABLE
    , a60 out nocopy JTF_DATE_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_DATE_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_VARCHAR2_TABLE_200
    , a80 out nocopy JTF_VARCHAR2_TABLE_200
    , a81 out nocopy JTF_VARCHAR2_TABLE_200
    , a82 out nocopy JTF_VARCHAR2_TABLE_200
    , a83 out nocopy JTF_VARCHAR2_TABLE_200
    , a84 out nocopy JTF_VARCHAR2_TABLE_200
    , a85 out nocopy JTF_VARCHAR2_TABLE_200
    , a86 out nocopy JTF_VARCHAR2_TABLE_200
    , a87 out nocopy JTF_VARCHAR2_TABLE_200
    , a88 out nocopy JTF_VARCHAR2_TABLE_200
    , a89 out nocopy JTF_VARCHAR2_TABLE_200
    , a90 out nocopy JTF_VARCHAR2_TABLE_200
    , a91 out nocopy JTF_VARCHAR2_TABLE_200
    , a92 out nocopy JTF_VARCHAR2_TABLE_200
    , a93 out nocopy JTF_VARCHAR2_TABLE_200
    , a94 out nocopy JTF_VARCHAR2_TABLE_100
    , a95 out nocopy JTF_VARCHAR2_TABLE_100
    , a96 out nocopy JTF_NUMBER_TABLE
    , a97 out nocopy JTF_DATE_TABLE
    , a98 out nocopy JTF_DATE_TABLE
    , a99 out nocopy JTF_NUMBER_TABLE
    , a100 out nocopy JTF_NUMBER_TABLE
    , a101 out nocopy JTF_NUMBER_TABLE
    , a102 out nocopy JTF_NUMBER_TABLE
    , a103 out nocopy JTF_NUMBER_TABLE
    , a104 out nocopy JTF_NUMBER_TABLE
    , a105 out nocopy JTF_VARCHAR2_TABLE_100
    , a106 out nocopy JTF_VARCHAR2_TABLE_100
    , a107 out nocopy JTF_VARCHAR2_TABLE_100
    , a108 out nocopy JTF_NUMBER_TABLE
    , a109 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_DATE_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_NUMBER_TABLE();
    a57 := JTF_DATE_TABLE();
    a58 := JTF_DATE_TABLE();
    a59 := JTF_DATE_TABLE();
    a60 := JTF_DATE_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_NUMBER_TABLE();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_NUMBER_TABLE();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_DATE_TABLE();
    a70 := JTF_NUMBER_TABLE();
    a71 := JTF_NUMBER_TABLE();
    a72 := JTF_NUMBER_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_NUMBER_TABLE();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_VARCHAR2_TABLE_100();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_VARCHAR2_TABLE_200();
    a80 := JTF_VARCHAR2_TABLE_200();
    a81 := JTF_VARCHAR2_TABLE_200();
    a82 := JTF_VARCHAR2_TABLE_200();
    a83 := JTF_VARCHAR2_TABLE_200();
    a84 := JTF_VARCHAR2_TABLE_200();
    a85 := JTF_VARCHAR2_TABLE_200();
    a86 := JTF_VARCHAR2_TABLE_200();
    a87 := JTF_VARCHAR2_TABLE_200();
    a88 := JTF_VARCHAR2_TABLE_200();
    a89 := JTF_VARCHAR2_TABLE_200();
    a90 := JTF_VARCHAR2_TABLE_200();
    a91 := JTF_VARCHAR2_TABLE_200();
    a92 := JTF_VARCHAR2_TABLE_200();
    a93 := JTF_VARCHAR2_TABLE_200();
    a94 := JTF_VARCHAR2_TABLE_100();
    a95 := JTF_VARCHAR2_TABLE_100();
    a96 := JTF_NUMBER_TABLE();
    a97 := JTF_DATE_TABLE();
    a98 := JTF_DATE_TABLE();
    a99 := JTF_NUMBER_TABLE();
    a100 := JTF_NUMBER_TABLE();
    a101 := JTF_NUMBER_TABLE();
    a102 := JTF_NUMBER_TABLE();
    a103 := JTF_NUMBER_TABLE();
    a104 := JTF_NUMBER_TABLE();
    a105 := JTF_VARCHAR2_TABLE_100();
    a106 := JTF_VARCHAR2_TABLE_100();
    a107 := JTF_VARCHAR2_TABLE_100();
    a108 := JTF_NUMBER_TABLE();
    a109 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_DATE_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_NUMBER_TABLE();
      a57 := JTF_DATE_TABLE();
      a58 := JTF_DATE_TABLE();
      a59 := JTF_DATE_TABLE();
      a60 := JTF_DATE_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_NUMBER_TABLE();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_NUMBER_TABLE();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_DATE_TABLE();
      a70 := JTF_NUMBER_TABLE();
      a71 := JTF_NUMBER_TABLE();
      a72 := JTF_NUMBER_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_NUMBER_TABLE();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_VARCHAR2_TABLE_100();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_VARCHAR2_TABLE_200();
      a80 := JTF_VARCHAR2_TABLE_200();
      a81 := JTF_VARCHAR2_TABLE_200();
      a82 := JTF_VARCHAR2_TABLE_200();
      a83 := JTF_VARCHAR2_TABLE_200();
      a84 := JTF_VARCHAR2_TABLE_200();
      a85 := JTF_VARCHAR2_TABLE_200();
      a86 := JTF_VARCHAR2_TABLE_200();
      a87 := JTF_VARCHAR2_TABLE_200();
      a88 := JTF_VARCHAR2_TABLE_200();
      a89 := JTF_VARCHAR2_TABLE_200();
      a90 := JTF_VARCHAR2_TABLE_200();
      a91 := JTF_VARCHAR2_TABLE_200();
      a92 := JTF_VARCHAR2_TABLE_200();
      a93 := JTF_VARCHAR2_TABLE_200();
      a94 := JTF_VARCHAR2_TABLE_100();
      a95 := JTF_VARCHAR2_TABLE_100();
      a96 := JTF_NUMBER_TABLE();
      a97 := JTF_DATE_TABLE();
      a98 := JTF_DATE_TABLE();
      a99 := JTF_NUMBER_TABLE();
      a100 := JTF_NUMBER_TABLE();
      a101 := JTF_NUMBER_TABLE();
      a102 := JTF_NUMBER_TABLE();
      a103 := JTF_NUMBER_TABLE();
      a104 := JTF_NUMBER_TABLE();
      a105 := JTF_VARCHAR2_TABLE_100();
      a106 := JTF_VARCHAR2_TABLE_100();
      a107 := JTF_VARCHAR2_TABLE_100();
      a108 := JTF_NUMBER_TABLE();
      a109 := JTF_VARCHAR2_TABLE_100();
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
        a60.extend(t.count);
        a61.extend(t.count);
        a62.extend(t.count);
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        a69.extend(t.count);
        a70.extend(t.count);
        a71.extend(t.count);
        a72.extend(t.count);
        a73.extend(t.count);
        a74.extend(t.count);
        a75.extend(t.count);
        a76.extend(t.count);
        a77.extend(t.count);
        a78.extend(t.count);
        a79.extend(t.count);
        a80.extend(t.count);
        a81.extend(t.count);
        a82.extend(t.count);
        a83.extend(t.count);
        a84.extend(t.count);
        a85.extend(t.count);
        a86.extend(t.count);
        a87.extend(t.count);
        a88.extend(t.count);
        a89.extend(t.count);
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_name;
          a4(indx) := t(ddindx).wip_entity_id;
          a5(indx) := t(ddindx).organization_id;
          a6(indx) := t(ddindx).description;
          a7(indx) := t(ddindx).asset_number;
          a8(indx) := t(ddindx).asset_group_id;
          a9(indx) := t(ddindx).rebuild_item_id;
          a10(indx) := t(ddindx).rebuild_serial_number;
          a11(indx) := t(ddindx).maintenance_object_id;
          a12(indx) := t(ddindx).maintenance_object_type;
          a13(indx) := t(ddindx).maintenance_object_source;
          a14(indx) := t(ddindx).eam_linear_location_id;
          a15(indx) := t(ddindx).class_code;
          a16(indx) := t(ddindx).asset_activity_id;
          a17(indx) := t(ddindx).activity_type;
          a18(indx) := t(ddindx).activity_cause;
          a19(indx) := t(ddindx).activity_source;
          a20(indx) := t(ddindx).work_order_type;
          a21(indx) := t(ddindx).status_type;
          a22(indx) := t(ddindx).job_quantity;
          a23(indx) := t(ddindx).date_released;
          a24(indx) := t(ddindx).owning_department;
          a25(indx) := t(ddindx).priority;
          a26(indx) := t(ddindx).requested_start_date;
          a27(indx) := t(ddindx).due_date;
          a28(indx) := t(ddindx).shutdown_type;
          a29(indx) := t(ddindx).firm_planned_flag;
          a30(indx) := t(ddindx).notification_required;
          a31(indx) := t(ddindx).tagout_required;
          a32(indx) := t(ddindx).plan_maintenance;
          a33(indx) := t(ddindx).project_id;
          a34(indx) := t(ddindx).task_id;
          a35(indx) := t(ddindx).end_item_unit_number;
          a36(indx) := t(ddindx).schedule_group_id;
          a37(indx) := t(ddindx).bom_revision_date;
          a38(indx) := t(ddindx).routing_revision_date;
          a39(indx) := t(ddindx).alternate_routing_designator;
          a40(indx) := t(ddindx).alternate_bom_designator;
          a41(indx) := t(ddindx).routing_revision;
          a42(indx) := t(ddindx).bom_revision;
          a43(indx) := t(ddindx).parent_wip_entity_id;
          a44(indx) := t(ddindx).manual_rebuild_flag;
          a45(indx) := t(ddindx).pm_schedule_id;
          a46(indx) := t(ddindx).wip_supply_type;
          a47(indx) := t(ddindx).material_account;
          a48(indx) := t(ddindx).material_overhead_account;
          a49(indx) := t(ddindx).resource_account;
          a50(indx) := t(ddindx).outside_processing_account;
          a51(indx) := t(ddindx).material_variance_account;
          a52(indx) := t(ddindx).resource_variance_account;
          a53(indx) := t(ddindx).outside_proc_variance_account;
          a54(indx) := t(ddindx).std_cost_adjustment_account;
          a55(indx) := t(ddindx).overhead_account;
          a56(indx) := t(ddindx).overhead_variance_account;
          a57(indx) := t(ddindx).scheduled_start_date;
          a58(indx) := t(ddindx).scheduled_completion_date;
          a59(indx) := t(ddindx).pm_suggested_start_date;
          a60(indx) := t(ddindx).pm_suggested_end_date;
          a61(indx) := t(ddindx).pm_base_meter_reading;
          a62(indx) := t(ddindx).pm_base_meter;
          a63(indx) := t(ddindx).common_bom_sequence_id;
          a64(indx) := t(ddindx).common_routing_sequence_id;
          a65(indx) := t(ddindx).po_creation_time;
          a66(indx) := t(ddindx).gen_object_id;
          a67(indx) := t(ddindx).user_defined_status_id;
          a68(indx) := t(ddindx).pending_flag;
          a69(indx) := t(ddindx).material_shortage_check_date;
          a70(indx) := t(ddindx).material_shortage_flag;
          a71(indx) := t(ddindx).workflow_type;
          a72(indx) := t(ddindx).warranty_claim_status;
          a73(indx) := t(ddindx).cycle_id;
          a74(indx) := t(ddindx).seq_id;
          a75(indx) := t(ddindx).ds_scheduled_flag;
          a76(indx) := t(ddindx).warranty_active;
          a77(indx) := t(ddindx).assignment_complete;
          a78(indx) := t(ddindx).attribute_category;
          a79(indx) := t(ddindx).attribute1;
          a80(indx) := t(ddindx).attribute2;
          a81(indx) := t(ddindx).attribute3;
          a82(indx) := t(ddindx).attribute4;
          a83(indx) := t(ddindx).attribute5;
          a84(indx) := t(ddindx).attribute6;
          a85(indx) := t(ddindx).attribute7;
          a86(indx) := t(ddindx).attribute8;
          a87(indx) := t(ddindx).attribute9;
          a88(indx) := t(ddindx).attribute10;
          a89(indx) := t(ddindx).attribute11;
          a90(indx) := t(ddindx).attribute12;
          a91(indx) := t(ddindx).attribute13;
          a92(indx) := t(ddindx).attribute14;
          a93(indx) := t(ddindx).attribute15;
          a94(indx) := t(ddindx).material_issue_by_mo;
          a95(indx) := t(ddindx).issue_zero_cost_flag;
          a96(indx) := t(ddindx).report_type;
          a97(indx) := t(ddindx).actual_close_date;
          a98(indx) := t(ddindx).submission_date;
          a99(indx) := t(ddindx).user_id;
          a100(indx) := t(ddindx).responsibility_id;
          a101(indx) := t(ddindx).request_id;
          a102(indx) := t(ddindx).program_id;
          a103(indx) := t(ddindx).program_application_id;
          a104(indx) := t(ddindx).source_line_id;
          a105(indx) := t(ddindx).source_code;
          a106(indx) := t(ddindx).validate_structure;
          a107(indx) := t(ddindx).return_status;
          a108(indx) := t(ddindx).transaction_type;
          a109(indx) := t(ddindx).failure_code_required;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p27;

  procedure rosetta_table_copy_in_p28(t out nocopy eam_process_wo_pub.eam_op_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
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
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_4000
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).organization_id := a4(indx);
          t(ddindx).operation_seq_num := a5(indx);
          t(ddindx).standard_operation_id := a6(indx);
          t(ddindx).department_id := a7(indx);
          t(ddindx).operation_sequence_id := a8(indx);
          t(ddindx).description := a9(indx);
          t(ddindx).minimum_transfer_quantity := a10(indx);
          t(ddindx).count_point_type := a11(indx);
          t(ddindx).backflush_flag := a12(indx);
          t(ddindx).shutdown_type := a13(indx);
          t(ddindx).start_date := a14(indx);
          t(ddindx).completion_date := a15(indx);
          t(ddindx).attribute_category := a16(indx);
          t(ddindx).attribute1 := a17(indx);
          t(ddindx).attribute2 := a18(indx);
          t(ddindx).attribute3 := a19(indx);
          t(ddindx).attribute4 := a20(indx);
          t(ddindx).attribute5 := a21(indx);
          t(ddindx).attribute6 := a22(indx);
          t(ddindx).attribute7 := a23(indx);
          t(ddindx).attribute8 := a24(indx);
          t(ddindx).attribute9 := a25(indx);
          t(ddindx).attribute10 := a26(indx);
          t(ddindx).attribute11 := a27(indx);
          t(ddindx).attribute12 := a28(indx);
          t(ddindx).attribute13 := a29(indx);
          t(ddindx).attribute14 := a30(indx);
          t(ddindx).attribute15 := a31(indx);
          t(ddindx).long_description := a32(indx);
          t(ddindx).request_id := a33(indx);
          t(ddindx).program_application_id := a34(indx);
          t(ddindx).program_id := a35(indx);
          t(ddindx).return_status := a36(indx);
          t(ddindx).transaction_type := a37(indx);
          t(ddindx).x_pos := a38(indx);
          t(ddindx).y_pos := a39(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p28;
  procedure rosetta_table_copy_out_p28(t eam_process_wo_pub.eam_op_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_4000
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
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
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
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
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_4000();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
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
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_4000();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).organization_id;
          a5(indx) := t(ddindx).operation_seq_num;
          a6(indx) := t(ddindx).standard_operation_id;
          a7(indx) := t(ddindx).department_id;
          a8(indx) := t(ddindx).operation_sequence_id;
          a9(indx) := t(ddindx).description;
          a10(indx) := t(ddindx).minimum_transfer_quantity;
          a11(indx) := t(ddindx).count_point_type;
          a12(indx) := t(ddindx).backflush_flag;
          a13(indx) := t(ddindx).shutdown_type;
          a14(indx) := t(ddindx).start_date;
          a15(indx) := t(ddindx).completion_date;
          a16(indx) := t(ddindx).attribute_category;
          a17(indx) := t(ddindx).attribute1;
          a18(indx) := t(ddindx).attribute2;
          a19(indx) := t(ddindx).attribute3;
          a20(indx) := t(ddindx).attribute4;
          a21(indx) := t(ddindx).attribute5;
          a22(indx) := t(ddindx).attribute6;
          a23(indx) := t(ddindx).attribute7;
          a24(indx) := t(ddindx).attribute8;
          a25(indx) := t(ddindx).attribute9;
          a26(indx) := t(ddindx).attribute10;
          a27(indx) := t(ddindx).attribute11;
          a28(indx) := t(ddindx).attribute12;
          a29(indx) := t(ddindx).attribute13;
          a30(indx) := t(ddindx).attribute14;
          a31(indx) := t(ddindx).attribute15;
          a32(indx) := t(ddindx).long_description;
          a33(indx) := t(ddindx).request_id;
          a34(indx) := t(ddindx).program_application_id;
          a35(indx) := t(ddindx).program_id;
          a36(indx) := t(ddindx).return_status;
          a37(indx) := t(ddindx).transaction_type;
          a38(indx) := t(ddindx).x_pos;
          a39(indx) := t(ddindx).y_pos;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p28;

  procedure rosetta_table_copy_in_p29(t out nocopy eam_process_wo_pub.eam_op_network_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).organization_id := a4(indx);
          t(ddindx).prior_operation := a5(indx);
          t(ddindx).next_operation := a6(indx);
          t(ddindx).attribute_category := a7(indx);
          t(ddindx).attribute1 := a8(indx);
          t(ddindx).attribute2 := a9(indx);
          t(ddindx).attribute3 := a10(indx);
          t(ddindx).attribute4 := a11(indx);
          t(ddindx).attribute5 := a12(indx);
          t(ddindx).attribute6 := a13(indx);
          t(ddindx).attribute7 := a14(indx);
          t(ddindx).attribute8 := a15(indx);
          t(ddindx).attribute9 := a16(indx);
          t(ddindx).attribute10 := a17(indx);
          t(ddindx).attribute11 := a18(indx);
          t(ddindx).attribute12 := a19(indx);
          t(ddindx).attribute13 := a20(indx);
          t(ddindx).attribute14 := a21(indx);
          t(ddindx).attribute15 := a22(indx);
          t(ddindx).return_status := a23(indx);
          t(ddindx).transaction_type := a24(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p29;
  procedure rosetta_table_copy_out_p29(t eam_process_wo_pub.eam_op_network_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).organization_id;
          a5(indx) := t(ddindx).prior_operation;
          a6(indx) := t(ddindx).next_operation;
          a7(indx) := t(ddindx).attribute_category;
          a8(indx) := t(ddindx).attribute1;
          a9(indx) := t(ddindx).attribute2;
          a10(indx) := t(ddindx).attribute3;
          a11(indx) := t(ddindx).attribute4;
          a12(indx) := t(ddindx).attribute5;
          a13(indx) := t(ddindx).attribute6;
          a14(indx) := t(ddindx).attribute7;
          a15(indx) := t(ddindx).attribute8;
          a16(indx) := t(ddindx).attribute9;
          a17(indx) := t(ddindx).attribute10;
          a18(indx) := t(ddindx).attribute11;
          a19(indx) := t(ddindx).attribute12;
          a20(indx) := t(ddindx).attribute13;
          a21(indx) := t(ddindx).attribute14;
          a22(indx) := t(ddindx).attribute15;
          a23(indx) := t(ddindx).return_status;
          a24(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p29;

  procedure rosetta_table_copy_in_p30(t out nocopy eam_process_wo_pub.eam_res_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_200
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
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).organization_id := a4(indx);
          t(ddindx).operation_seq_num := a5(indx);
          t(ddindx).resource_seq_num := a6(indx);
          t(ddindx).resource_id := a7(indx);
          t(ddindx).uom_code := a8(indx);
          t(ddindx).basis_type := a9(indx);
          t(ddindx).usage_rate_or_amount := a10(indx);
          t(ddindx).activity_id := a11(indx);
          t(ddindx).scheduled_flag := a12(indx);
          t(ddindx).firm_flag := a13(indx);
          t(ddindx).assigned_units := a14(indx);
          t(ddindx).maximum_assigned_units := a15(indx);
          t(ddindx).autocharge_type := a16(indx);
          t(ddindx).standard_rate_flag := a17(indx);
          t(ddindx).applied_resource_units := a18(indx);
          t(ddindx).applied_resource_value := a19(indx);
          t(ddindx).start_date := a20(indx);
          t(ddindx).completion_date := a21(indx);
          t(ddindx).schedule_seq_num := a22(indx);
          t(ddindx).substitute_group_num := a23(indx);
          t(ddindx).replacement_group_num := a24(indx);
          t(ddindx).attribute_category := a25(indx);
          t(ddindx).attribute1 := a26(indx);
          t(ddindx).attribute2 := a27(indx);
          t(ddindx).attribute3 := a28(indx);
          t(ddindx).attribute4 := a29(indx);
          t(ddindx).attribute5 := a30(indx);
          t(ddindx).attribute6 := a31(indx);
          t(ddindx).attribute7 := a32(indx);
          t(ddindx).attribute8 := a33(indx);
          t(ddindx).attribute9 := a34(indx);
          t(ddindx).attribute10 := a35(indx);
          t(ddindx).attribute11 := a36(indx);
          t(ddindx).attribute12 := a37(indx);
          t(ddindx).attribute13 := a38(indx);
          t(ddindx).attribute14 := a39(indx);
          t(ddindx).attribute15 := a40(indx);
          t(ddindx).department_id := a41(indx);
          t(ddindx).request_id := a42(indx);
          t(ddindx).program_application_id := a43(indx);
          t(ddindx).program_id := a44(indx);
          t(ddindx).program_update_date := a45(indx);
          t(ddindx).return_status := a46(indx);
          t(ddindx).transaction_type := a47(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p30;
  procedure rosetta_table_copy_out_p30(t eam_process_wo_pub.eam_res_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_NUMBER_TABLE
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
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_200();
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
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_DATE_TABLE();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_NUMBER_TABLE();
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
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_200();
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
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_DATE_TABLE();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).organization_id;
          a5(indx) := t(ddindx).operation_seq_num;
          a6(indx) := t(ddindx).resource_seq_num;
          a7(indx) := t(ddindx).resource_id;
          a8(indx) := t(ddindx).uom_code;
          a9(indx) := t(ddindx).basis_type;
          a10(indx) := t(ddindx).usage_rate_or_amount;
          a11(indx) := t(ddindx).activity_id;
          a12(indx) := t(ddindx).scheduled_flag;
          a13(indx) := t(ddindx).firm_flag;
          a14(indx) := t(ddindx).assigned_units;
          a15(indx) := t(ddindx).maximum_assigned_units;
          a16(indx) := t(ddindx).autocharge_type;
          a17(indx) := t(ddindx).standard_rate_flag;
          a18(indx) := t(ddindx).applied_resource_units;
          a19(indx) := t(ddindx).applied_resource_value;
          a20(indx) := t(ddindx).start_date;
          a21(indx) := t(ddindx).completion_date;
          a22(indx) := t(ddindx).schedule_seq_num;
          a23(indx) := t(ddindx).substitute_group_num;
          a24(indx) := t(ddindx).replacement_group_num;
          a25(indx) := t(ddindx).attribute_category;
          a26(indx) := t(ddindx).attribute1;
          a27(indx) := t(ddindx).attribute2;
          a28(indx) := t(ddindx).attribute3;
          a29(indx) := t(ddindx).attribute4;
          a30(indx) := t(ddindx).attribute5;
          a31(indx) := t(ddindx).attribute6;
          a32(indx) := t(ddindx).attribute7;
          a33(indx) := t(ddindx).attribute8;
          a34(indx) := t(ddindx).attribute9;
          a35(indx) := t(ddindx).attribute10;
          a36(indx) := t(ddindx).attribute11;
          a37(indx) := t(ddindx).attribute12;
          a38(indx) := t(ddindx).attribute13;
          a39(indx) := t(ddindx).attribute14;
          a40(indx) := t(ddindx).attribute15;
          a41(indx) := t(ddindx).department_id;
          a42(indx) := t(ddindx).request_id;
          a43(indx) := t(ddindx).program_application_id;
          a44(indx) := t(ddindx).program_id;
          a45(indx) := t(ddindx).program_update_date;
          a46(indx) := t(ddindx).return_status;
          a47(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p30;

  procedure rosetta_table_copy_in_p31(t out nocopy eam_process_wo_pub.eam_res_inst_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).organization_id := a4(indx);
          t(ddindx).operation_seq_num := a5(indx);
          t(ddindx).resource_seq_num := a6(indx);
          t(ddindx).instance_id := a7(indx);
          t(ddindx).serial_number := a8(indx);
          t(ddindx).start_date := a9(indx);
          t(ddindx).completion_date := a10(indx);
          t(ddindx).top_level_batch_id := a11(indx);
          t(ddindx).return_status := a12(indx);
          t(ddindx).transaction_type := a13(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p31;
  procedure rosetta_table_copy_out_p31(t eam_process_wo_pub.eam_res_inst_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
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
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
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
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).organization_id;
          a5(indx) := t(ddindx).operation_seq_num;
          a6(indx) := t(ddindx).resource_seq_num;
          a7(indx) := t(ddindx).instance_id;
          a8(indx) := t(ddindx).serial_number;
          a9(indx) := t(ddindx).start_date;
          a10(indx) := t(ddindx).completion_date;
          a11(indx) := t(ddindx).top_level_batch_id;
          a12(indx) := t(ddindx).return_status;
          a13(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p31;

  procedure rosetta_table_copy_in_p32(t out nocopy eam_process_wo_pub.eam_sub_res_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
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
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_DATE_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).organization_id := a4(indx);
          t(ddindx).operation_seq_num := a5(indx);
          t(ddindx).resource_seq_num := a6(indx);
          t(ddindx).resource_id := a7(indx);
          t(ddindx).uom_code := a8(indx);
          t(ddindx).basis_type := a9(indx);
          t(ddindx).usage_rate_or_amount := a10(indx);
          t(ddindx).activity_id := a11(indx);
          t(ddindx).scheduled_flag := a12(indx);
          t(ddindx).assigned_units := a13(indx);
          t(ddindx).autocharge_type := a14(indx);
          t(ddindx).standard_rate_flag := a15(indx);
          t(ddindx).applied_resource_units := a16(indx);
          t(ddindx).applied_resource_value := a17(indx);
          t(ddindx).start_date := a18(indx);
          t(ddindx).completion_date := a19(indx);
          t(ddindx).schedule_seq_num := a20(indx);
          t(ddindx).substitute_group_num := a21(indx);
          t(ddindx).replacement_group_num := a22(indx);
          t(ddindx).attribute_category := a23(indx);
          t(ddindx).attribute1 := a24(indx);
          t(ddindx).attribute2 := a25(indx);
          t(ddindx).attribute3 := a26(indx);
          t(ddindx).attribute4 := a27(indx);
          t(ddindx).attribute5 := a28(indx);
          t(ddindx).attribute6 := a29(indx);
          t(ddindx).attribute7 := a30(indx);
          t(ddindx).attribute8 := a31(indx);
          t(ddindx).attribute9 := a32(indx);
          t(ddindx).attribute10 := a33(indx);
          t(ddindx).attribute11 := a34(indx);
          t(ddindx).attribute12 := a35(indx);
          t(ddindx).attribute13 := a36(indx);
          t(ddindx).attribute14 := a37(indx);
          t(ddindx).attribute15 := a38(indx);
          t(ddindx).department_id := a39(indx);
          t(ddindx).request_id := a40(indx);
          t(ddindx).program_application_id := a41(indx);
          t(ddindx).program_id := a42(indx);
          t(ddindx).program_update_date := a43(indx);
          t(ddindx).return_status := a44(indx);
          t(ddindx).transaction_type := a45(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p32;
  procedure rosetta_table_copy_out_p32(t eam_process_wo_pub.eam_sub_res_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_DATE_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
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
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
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
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_DATE_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_NUMBER_TABLE();
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
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
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
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_DATE_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).organization_id;
          a5(indx) := t(ddindx).operation_seq_num;
          a6(indx) := t(ddindx).resource_seq_num;
          a7(indx) := t(ddindx).resource_id;
          a8(indx) := t(ddindx).uom_code;
          a9(indx) := t(ddindx).basis_type;
          a10(indx) := t(ddindx).usage_rate_or_amount;
          a11(indx) := t(ddindx).activity_id;
          a12(indx) := t(ddindx).scheduled_flag;
          a13(indx) := t(ddindx).assigned_units;
          a14(indx) := t(ddindx).autocharge_type;
          a15(indx) := t(ddindx).standard_rate_flag;
          a16(indx) := t(ddindx).applied_resource_units;
          a17(indx) := t(ddindx).applied_resource_value;
          a18(indx) := t(ddindx).start_date;
          a19(indx) := t(ddindx).completion_date;
          a20(indx) := t(ddindx).schedule_seq_num;
          a21(indx) := t(ddindx).substitute_group_num;
          a22(indx) := t(ddindx).replacement_group_num;
          a23(indx) := t(ddindx).attribute_category;
          a24(indx) := t(ddindx).attribute1;
          a25(indx) := t(ddindx).attribute2;
          a26(indx) := t(ddindx).attribute3;
          a27(indx) := t(ddindx).attribute4;
          a28(indx) := t(ddindx).attribute5;
          a29(indx) := t(ddindx).attribute6;
          a30(indx) := t(ddindx).attribute7;
          a31(indx) := t(ddindx).attribute8;
          a32(indx) := t(ddindx).attribute9;
          a33(indx) := t(ddindx).attribute10;
          a34(indx) := t(ddindx).attribute11;
          a35(indx) := t(ddindx).attribute12;
          a36(indx) := t(ddindx).attribute13;
          a37(indx) := t(ddindx).attribute14;
          a38(indx) := t(ddindx).attribute15;
          a39(indx) := t(ddindx).department_id;
          a40(indx) := t(ddindx).request_id;
          a41(indx) := t(ddindx).program_application_id;
          a42(indx) := t(ddindx).program_id;
          a43(indx) := t(ddindx).program_update_date;
          a44(indx) := t(ddindx).return_status;
          a45(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p32;

  procedure rosetta_table_copy_in_p33(t out nocopy eam_process_wo_pub.eam_res_usage_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).operation_seq_num := a4(indx);
          t(ddindx).resource_seq_num := a5(indx);
          t(ddindx).organization_id := a6(indx);
          t(ddindx).start_date := a7(indx);
          t(ddindx).completion_date := a8(indx);
          t(ddindx).old_start_date := a9(indx);
          t(ddindx).old_completion_date := a10(indx);
          t(ddindx).assigned_units := a11(indx);
          t(ddindx).request_id := a12(indx);
          t(ddindx).program_application_id := a13(indx);
          t(ddindx).program_id := a14(indx);
          t(ddindx).program_update_date := a15(indx);
          t(ddindx).instance_id := a16(indx);
          t(ddindx).serial_number := a17(indx);
          t(ddindx).return_status := a18(indx);
          t(ddindx).transaction_type := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p33;
  procedure rosetta_table_copy_out_p33(t eam_process_wo_pub.eam_res_usage_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).operation_seq_num;
          a5(indx) := t(ddindx).resource_seq_num;
          a6(indx) := t(ddindx).organization_id;
          a7(indx) := t(ddindx).start_date;
          a8(indx) := t(ddindx).completion_date;
          a9(indx) := t(ddindx).old_start_date;
          a10(indx) := t(ddindx).old_completion_date;
          a11(indx) := t(ddindx).assigned_units;
          a12(indx) := t(ddindx).request_id;
          a13(indx) := t(ddindx).program_application_id;
          a14(indx) := t(ddindx).program_id;
          a15(indx) := t(ddindx).program_update_date;
          a16(indx) := t(ddindx).instance_id;
          a17(indx) := t(ddindx).serial_number;
          a18(indx) := t(ddindx).return_status;
          a19(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p33;

  procedure rosetta_table_copy_in_p34(t out nocopy eam_process_wo_pub.eam_mat_req_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_DATE_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
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
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).organization_id := a4(indx);
          t(ddindx).operation_seq_num := a5(indx);
          t(ddindx).inventory_item_id := a6(indx);
          t(ddindx).quantity_per_assembly := a7(indx);
          t(ddindx).department_id := a8(indx);
          t(ddindx).wip_supply_type := a9(indx);
          t(ddindx).date_required := a10(indx);
          t(ddindx).required_quantity := a11(indx);
          t(ddindx).requested_quantity := a12(indx);
          t(ddindx).released_quantity := a13(indx);
          t(ddindx).quantity_issued := a14(indx);
          t(ddindx).supply_subinventory := a15(indx);
          t(ddindx).supply_locator_id := a16(indx);
          t(ddindx).mrp_net_flag := a17(indx);
          t(ddindx).mps_required_quantity := a18(indx);
          t(ddindx).mps_date_required := a19(indx);
          t(ddindx).component_sequence_id := a20(indx);
          t(ddindx).comments := a21(indx);
          t(ddindx).attribute_category := a22(indx);
          t(ddindx).attribute1 := a23(indx);
          t(ddindx).attribute2 := a24(indx);
          t(ddindx).attribute3 := a25(indx);
          t(ddindx).attribute4 := a26(indx);
          t(ddindx).attribute5 := a27(indx);
          t(ddindx).attribute6 := a28(indx);
          t(ddindx).attribute7 := a29(indx);
          t(ddindx).attribute8 := a30(indx);
          t(ddindx).attribute9 := a31(indx);
          t(ddindx).attribute10 := a32(indx);
          t(ddindx).attribute11 := a33(indx);
          t(ddindx).attribute12 := a34(indx);
          t(ddindx).attribute13 := a35(indx);
          t(ddindx).attribute14 := a36(indx);
          t(ddindx).attribute15 := a37(indx);
          t(ddindx).auto_request_material := a38(indx);
          t(ddindx).suggested_vendor_name := a39(indx);
          t(ddindx).vendor_id := a40(indx);
          t(ddindx).unit_price := a41(indx);
          t(ddindx).request_id := a42(indx);
          t(ddindx).program_application_id := a43(indx);
          t(ddindx).program_id := a44(indx);
          t(ddindx).program_update_date := a45(indx);
          t(ddindx).return_status := a46(indx);
          t(ddindx).transaction_type := a47(indx);
          t(ddindx).invoke_allocations_api := a48(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p34;
  procedure rosetta_table_copy_out_p34(t eam_process_wo_pub.eam_mat_req_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
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
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
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
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_DATE_TABLE();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
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
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_DATE_TABLE();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).organization_id;
          a5(indx) := t(ddindx).operation_seq_num;
          a6(indx) := t(ddindx).inventory_item_id;
          a7(indx) := t(ddindx).quantity_per_assembly;
          a8(indx) := t(ddindx).department_id;
          a9(indx) := t(ddindx).wip_supply_type;
          a10(indx) := t(ddindx).date_required;
          a11(indx) := t(ddindx).required_quantity;
          a12(indx) := t(ddindx).requested_quantity;
          a13(indx) := t(ddindx).released_quantity;
          a14(indx) := t(ddindx).quantity_issued;
          a15(indx) := t(ddindx).supply_subinventory;
          a16(indx) := t(ddindx).supply_locator_id;
          a17(indx) := t(ddindx).mrp_net_flag;
          a18(indx) := t(ddindx).mps_required_quantity;
          a19(indx) := t(ddindx).mps_date_required;
          a20(indx) := t(ddindx).component_sequence_id;
          a21(indx) := t(ddindx).comments;
          a22(indx) := t(ddindx).attribute_category;
          a23(indx) := t(ddindx).attribute1;
          a24(indx) := t(ddindx).attribute2;
          a25(indx) := t(ddindx).attribute3;
          a26(indx) := t(ddindx).attribute4;
          a27(indx) := t(ddindx).attribute5;
          a28(indx) := t(ddindx).attribute6;
          a29(indx) := t(ddindx).attribute7;
          a30(indx) := t(ddindx).attribute8;
          a31(indx) := t(ddindx).attribute9;
          a32(indx) := t(ddindx).attribute10;
          a33(indx) := t(ddindx).attribute11;
          a34(indx) := t(ddindx).attribute12;
          a35(indx) := t(ddindx).attribute13;
          a36(indx) := t(ddindx).attribute14;
          a37(indx) := t(ddindx).attribute15;
          a38(indx) := t(ddindx).auto_request_material;
          a39(indx) := t(ddindx).suggested_vendor_name;
          a40(indx) := t(ddindx).vendor_id;
          a41(indx) := t(ddindx).unit_price;
          a42(indx) := t(ddindx).request_id;
          a43(indx) := t(ddindx).program_application_id;
          a44(indx) := t(ddindx).program_id;
          a45(indx) := t(ddindx).program_update_date;
          a46(indx) := t(ddindx).return_status;
          a47(indx) := t(ddindx).transaction_type;
          a48(indx) := t(ddindx).invoke_allocations_api;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p34;

  procedure rosetta_table_copy_in_p35(t out nocopy eam_process_wo_pub.eam_direct_items_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_DATE_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
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
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).purchasing_category_id := a4(indx);
          t(ddindx).direct_item_sequence_id := a5(indx);
          t(ddindx).operation_seq_num := a6(indx);
          t(ddindx).department_id := a7(indx);
          t(ddindx).wip_entity_id := a8(indx);
          t(ddindx).organization_id := a9(indx);
          t(ddindx).suggested_vendor_name := a10(indx);
          t(ddindx).suggested_vendor_id := a11(indx);
          t(ddindx).suggested_vendor_site := a12(indx);
          t(ddindx).suggested_vendor_site_id := a13(indx);
          t(ddindx).suggested_vendor_contact := a14(indx);
          t(ddindx).suggested_vendor_contact_id := a15(indx);
          t(ddindx).suggested_vendor_phone := a16(indx);
          t(ddindx).suggested_vendor_item_num := a17(indx);
          t(ddindx).unit_price := a18(indx);
          t(ddindx).auto_request_material := a19(indx);
          t(ddindx).required_quantity := a20(indx);
          t(ddindx).requested_quantity := a21(indx);
          t(ddindx).uom := a22(indx);
          t(ddindx).need_by_date := a23(indx);
          t(ddindx).attribute_category := a24(indx);
          t(ddindx).attribute1 := a25(indx);
          t(ddindx).attribute2 := a26(indx);
          t(ddindx).attribute3 := a27(indx);
          t(ddindx).attribute4 := a28(indx);
          t(ddindx).attribute5 := a29(indx);
          t(ddindx).attribute6 := a30(indx);
          t(ddindx).attribute7 := a31(indx);
          t(ddindx).attribute8 := a32(indx);
          t(ddindx).attribute9 := a33(indx);
          t(ddindx).attribute10 := a34(indx);
          t(ddindx).attribute11 := a35(indx);
          t(ddindx).attribute12 := a36(indx);
          t(ddindx).attribute13 := a37(indx);
          t(ddindx).attribute14 := a38(indx);
          t(ddindx).attribute15 := a39(indx);
          t(ddindx).program_application_id := a40(indx);
          t(ddindx).program_id := a41(indx);
          t(ddindx).program_update_date := a42(indx);
          t(ddindx).request_id := a43(indx);
          t(ddindx).return_status := a44(indx);
          t(ddindx).transaction_type := a45(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p35;
  procedure rosetta_table_copy_out_p35(t eam_process_wo_pub.eam_direct_items_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_DATE_TABLE();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
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
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_DATE_TABLE();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
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
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).description;
          a4(indx) := t(ddindx).purchasing_category_id;
          a5(indx) := t(ddindx).direct_item_sequence_id;
          a6(indx) := t(ddindx).operation_seq_num;
          a7(indx) := t(ddindx).department_id;
          a8(indx) := t(ddindx).wip_entity_id;
          a9(indx) := t(ddindx).organization_id;
          a10(indx) := t(ddindx).suggested_vendor_name;
          a11(indx) := t(ddindx).suggested_vendor_id;
          a12(indx) := t(ddindx).suggested_vendor_site;
          a13(indx) := t(ddindx).suggested_vendor_site_id;
          a14(indx) := t(ddindx).suggested_vendor_contact;
          a15(indx) := t(ddindx).suggested_vendor_contact_id;
          a16(indx) := t(ddindx).suggested_vendor_phone;
          a17(indx) := t(ddindx).suggested_vendor_item_num;
          a18(indx) := t(ddindx).unit_price;
          a19(indx) := t(ddindx).auto_request_material;
          a20(indx) := t(ddindx).required_quantity;
          a21(indx) := t(ddindx).requested_quantity;
          a22(indx) := t(ddindx).uom;
          a23(indx) := t(ddindx).need_by_date;
          a24(indx) := t(ddindx).attribute_category;
          a25(indx) := t(ddindx).attribute1;
          a26(indx) := t(ddindx).attribute2;
          a27(indx) := t(ddindx).attribute3;
          a28(indx) := t(ddindx).attribute4;
          a29(indx) := t(ddindx).attribute5;
          a30(indx) := t(ddindx).attribute6;
          a31(indx) := t(ddindx).attribute7;
          a32(indx) := t(ddindx).attribute8;
          a33(indx) := t(ddindx).attribute9;
          a34(indx) := t(ddindx).attribute10;
          a35(indx) := t(ddindx).attribute11;
          a36(indx) := t(ddindx).attribute12;
          a37(indx) := t(ddindx).attribute13;
          a38(indx) := t(ddindx).attribute14;
          a39(indx) := t(ddindx).attribute15;
          a40(indx) := t(ddindx).program_application_id;
          a41(indx) := t(ddindx).program_id;
          a42(indx) := t(ddindx).program_update_date;
          a43(indx) := t(ddindx).request_id;
          a44(indx) := t(ddindx).return_status;
          a45(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p35;

  procedure rosetta_table_copy_in_p36(t out nocopy eam_process_wo_pub.eam_wo_comp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_DATE_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
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
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_DATE_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).transaction_id := a3(indx);
          t(ddindx).transaction_date := a4(indx);
          t(ddindx).wip_entity_id := a5(indx);
          t(ddindx).user_status_id := a6(indx);
          t(ddindx).wip_entity_name := a7(indx);
          t(ddindx).organization_id := a8(indx);
          t(ddindx).parent_wip_entity_id := a9(indx);
          t(ddindx).reference := a10(indx);
          t(ddindx).reconciliation_code := a11(indx);
          t(ddindx).acct_period_id := a12(indx);
          t(ddindx).qa_collection_id := a13(indx);
          t(ddindx).actual_start_date := a14(indx);
          t(ddindx).actual_end_date := a15(indx);
          t(ddindx).actual_duration := a16(indx);
          t(ddindx).primary_item_id := a17(indx);
          t(ddindx).asset_group_id := a18(indx);
          t(ddindx).rebuild_item_id := a19(indx);
          t(ddindx).asset_number := a20(indx);
          t(ddindx).rebuild_serial_number := a21(indx);
          t(ddindx).manual_rebuild_flag := a22(indx);
          t(ddindx).rebuild_job := a23(indx);
          t(ddindx).completion_subinventory := a24(indx);
          t(ddindx).completion_locator_id := a25(indx);
          t(ddindx).lot_number := a26(indx);
          t(ddindx).shutdown_start_date := a27(indx);
          t(ddindx).shutdown_end_date := a28(indx);
          t(ddindx).attribute_category := a29(indx);
          t(ddindx).attribute1 := a30(indx);
          t(ddindx).attribute2 := a31(indx);
          t(ddindx).attribute3 := a32(indx);
          t(ddindx).attribute4 := a33(indx);
          t(ddindx).attribute5 := a34(indx);
          t(ddindx).attribute6 := a35(indx);
          t(ddindx).attribute7 := a36(indx);
          t(ddindx).attribute8 := a37(indx);
          t(ddindx).attribute9 := a38(indx);
          t(ddindx).attribute10 := a39(indx);
          t(ddindx).attribute11 := a40(indx);
          t(ddindx).attribute12 := a41(indx);
          t(ddindx).attribute13 := a42(indx);
          t(ddindx).attribute14 := a43(indx);
          t(ddindx).attribute15 := a44(indx);
          t(ddindx).request_id := a45(indx);
          t(ddindx).program_update_date := a46(indx);
          t(ddindx).program_application_id := a47(indx);
          t(ddindx).program_id := a48(indx);
          t(ddindx).return_status := a49(indx);
          t(ddindx).transaction_type := a50(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p36;
  procedure rosetta_table_copy_out_p36(t eam_process_wo_pub.eam_wo_comp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
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
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_VARCHAR2_TABLE_200();
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_NUMBER_TABLE();
    a46 := JTF_DATE_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_100();
    a50 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
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
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_VARCHAR2_TABLE_200();
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_NUMBER_TABLE();
      a46 := JTF_DATE_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_100();
      a50 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).transaction_id;
          a4(indx) := t(ddindx).transaction_date;
          a5(indx) := t(ddindx).wip_entity_id;
          a6(indx) := t(ddindx).user_status_id;
          a7(indx) := t(ddindx).wip_entity_name;
          a8(indx) := t(ddindx).organization_id;
          a9(indx) := t(ddindx).parent_wip_entity_id;
          a10(indx) := t(ddindx).reference;
          a11(indx) := t(ddindx).reconciliation_code;
          a12(indx) := t(ddindx).acct_period_id;
          a13(indx) := t(ddindx).qa_collection_id;
          a14(indx) := t(ddindx).actual_start_date;
          a15(indx) := t(ddindx).actual_end_date;
          a16(indx) := t(ddindx).actual_duration;
          a17(indx) := t(ddindx).primary_item_id;
          a18(indx) := t(ddindx).asset_group_id;
          a19(indx) := t(ddindx).rebuild_item_id;
          a20(indx) := t(ddindx).asset_number;
          a21(indx) := t(ddindx).rebuild_serial_number;
          a22(indx) := t(ddindx).manual_rebuild_flag;
          a23(indx) := t(ddindx).rebuild_job;
          a24(indx) := t(ddindx).completion_subinventory;
          a25(indx) := t(ddindx).completion_locator_id;
          a26(indx) := t(ddindx).lot_number;
          a27(indx) := t(ddindx).shutdown_start_date;
          a28(indx) := t(ddindx).shutdown_end_date;
          a29(indx) := t(ddindx).attribute_category;
          a30(indx) := t(ddindx).attribute1;
          a31(indx) := t(ddindx).attribute2;
          a32(indx) := t(ddindx).attribute3;
          a33(indx) := t(ddindx).attribute4;
          a34(indx) := t(ddindx).attribute5;
          a35(indx) := t(ddindx).attribute6;
          a36(indx) := t(ddindx).attribute7;
          a37(indx) := t(ddindx).attribute8;
          a38(indx) := t(ddindx).attribute9;
          a39(indx) := t(ddindx).attribute10;
          a40(indx) := t(ddindx).attribute11;
          a41(indx) := t(ddindx).attribute12;
          a42(indx) := t(ddindx).attribute13;
          a43(indx) := t(ddindx).attribute14;
          a44(indx) := t(ddindx).attribute15;
          a45(indx) := t(ddindx).request_id;
          a46(indx) := t(ddindx).program_update_date;
          a47(indx) := t(ddindx).program_application_id;
          a48(indx) := t(ddindx).program_id;
          a49(indx) := t(ddindx).return_status;
          a50(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p36;

  procedure rosetta_table_copy_in_p37(t out nocopy eam_process_wo_pub.eam_op_comp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
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
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).transaction_id := a3(indx);
          t(ddindx).transaction_date := a4(indx);
          t(ddindx).wip_entity_id := a5(indx);
          t(ddindx).organization_id := a6(indx);
          t(ddindx).operation_seq_num := a7(indx);
          t(ddindx).department_id := a8(indx);
          t(ddindx).reference := a9(indx);
          t(ddindx).reconciliation_code := a10(indx);
          t(ddindx).acct_period_id := a11(indx);
          t(ddindx).qa_collection_id := a12(indx);
          t(ddindx).actual_start_date := a13(indx);
          t(ddindx).actual_end_date := a14(indx);
          t(ddindx).actual_duration := a15(indx);
          t(ddindx).shutdown_start_date := a16(indx);
          t(ddindx).shutdown_end_date := a17(indx);
          t(ddindx).handover_operation_seq_num := a18(indx);
          t(ddindx).reason_id := a19(indx);
          t(ddindx).vendor_contact_id := a20(indx);
          t(ddindx).vendor_id := a21(indx);
          t(ddindx).vendor_site_id := a22(indx);
          t(ddindx).transaction_reference := a23(indx);
          t(ddindx).attribute_category := a24(indx);
          t(ddindx).attribute1 := a25(indx);
          t(ddindx).attribute2 := a26(indx);
          t(ddindx).attribute3 := a27(indx);
          t(ddindx).attribute4 := a28(indx);
          t(ddindx).attribute5 := a29(indx);
          t(ddindx).attribute6 := a30(indx);
          t(ddindx).attribute7 := a31(indx);
          t(ddindx).attribute8 := a32(indx);
          t(ddindx).attribute9 := a33(indx);
          t(ddindx).attribute10 := a34(indx);
          t(ddindx).attribute11 := a35(indx);
          t(ddindx).attribute12 := a36(indx);
          t(ddindx).attribute13 := a37(indx);
          t(ddindx).attribute14 := a38(indx);
          t(ddindx).attribute15 := a39(indx);
          t(ddindx).request_id := a40(indx);
          t(ddindx).program_update_date := a41(indx);
          t(ddindx).program_application_id := a42(indx);
          t(ddindx).program_id := a43(indx);
          t(ddindx).return_status := a44(indx);
          t(ddindx).transaction_type := a45(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p37;
  procedure rosetta_table_copy_out_p37(t eam_process_wo_pub.eam_op_comp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
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
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
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
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).transaction_id;
          a4(indx) := t(ddindx).transaction_date;
          a5(indx) := t(ddindx).wip_entity_id;
          a6(indx) := t(ddindx).organization_id;
          a7(indx) := t(ddindx).operation_seq_num;
          a8(indx) := t(ddindx).department_id;
          a9(indx) := t(ddindx).reference;
          a10(indx) := t(ddindx).reconciliation_code;
          a11(indx) := t(ddindx).acct_period_id;
          a12(indx) := t(ddindx).qa_collection_id;
          a13(indx) := t(ddindx).actual_start_date;
          a14(indx) := t(ddindx).actual_end_date;
          a15(indx) := t(ddindx).actual_duration;
          a16(indx) := t(ddindx).shutdown_start_date;
          a17(indx) := t(ddindx).shutdown_end_date;
          a18(indx) := t(ddindx).handover_operation_seq_num;
          a19(indx) := t(ddindx).reason_id;
          a20(indx) := t(ddindx).vendor_contact_id;
          a21(indx) := t(ddindx).vendor_id;
          a22(indx) := t(ddindx).vendor_site_id;
          a23(indx) := t(ddindx).transaction_reference;
          a24(indx) := t(ddindx).attribute_category;
          a25(indx) := t(ddindx).attribute1;
          a26(indx) := t(ddindx).attribute2;
          a27(indx) := t(ddindx).attribute3;
          a28(indx) := t(ddindx).attribute4;
          a29(indx) := t(ddindx).attribute5;
          a30(indx) := t(ddindx).attribute6;
          a31(indx) := t(ddindx).attribute7;
          a32(indx) := t(ddindx).attribute8;
          a33(indx) := t(ddindx).attribute9;
          a34(indx) := t(ddindx).attribute10;
          a35(indx) := t(ddindx).attribute11;
          a36(indx) := t(ddindx).attribute12;
          a37(indx) := t(ddindx).attribute13;
          a38(indx) := t(ddindx).attribute14;
          a39(indx) := t(ddindx).attribute15;
          a40(indx) := t(ddindx).request_id;
          a41(indx) := t(ddindx).program_update_date;
          a42(indx) := t(ddindx).program_application_id;
          a43(indx) := t(ddindx).program_id;
          a44(indx) := t(ddindx).return_status;
          a45(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p37;

  procedure rosetta_table_copy_in_p38(t out nocopy eam_process_wo_pub.eam_meter_reading_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
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
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).meter_id := a4(indx);
          t(ddindx).meter_reading_id := a5(indx);
          t(ddindx).current_reading := a6(indx);
          t(ddindx).current_reading_date := a7(indx);
          t(ddindx).wo_end_date := a8(indx);
          t(ddindx).reset_flag := a9(indx);
          t(ddindx).value_before_reset := a10(indx);
          t(ddindx).ignore_meter_warnings := a11(indx);
          t(ddindx).attribute_category := a12(indx);
          t(ddindx).attribute1 := a13(indx);
          t(ddindx).attribute2 := a14(indx);
          t(ddindx).attribute3 := a15(indx);
          t(ddindx).attribute4 := a16(indx);
          t(ddindx).attribute5 := a17(indx);
          t(ddindx).attribute6 := a18(indx);
          t(ddindx).attribute7 := a19(indx);
          t(ddindx).attribute8 := a20(indx);
          t(ddindx).attribute9 := a21(indx);
          t(ddindx).attribute10 := a22(indx);
          t(ddindx).attribute11 := a23(indx);
          t(ddindx).attribute12 := a24(indx);
          t(ddindx).attribute13 := a25(indx);
          t(ddindx).attribute14 := a26(indx);
          t(ddindx).attribute15 := a27(indx);
          t(ddindx).attribute16 := a28(indx);
          t(ddindx).attribute17 := a29(indx);
          t(ddindx).attribute18 := a30(indx);
          t(ddindx).attribute19 := a31(indx);
          t(ddindx).attribute20 := a32(indx);
          t(ddindx).attribute21 := a33(indx);
          t(ddindx).attribute22 := a34(indx);
          t(ddindx).attribute23 := a35(indx);
          t(ddindx).attribute24 := a36(indx);
          t(ddindx).attribute25 := a37(indx);
          t(ddindx).attribute26 := a38(indx);
          t(ddindx).attribute27 := a39(indx);
          t(ddindx).attribute28 := a40(indx);
          t(ddindx).attribute29 := a41(indx);
          t(ddindx).attribute30 := a42(indx);
          t(ddindx).source_line_id := a43(indx);
          t(ddindx).source_code := a44(indx);
          t(ddindx).wo_entry_fake_flag := a45(indx);
          t(ddindx).return_status := a46(indx);
          t(ddindx).transaction_type := a47(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p38;
  procedure rosetta_table_copy_out_p38(t eam_process_wo_pub.eam_meter_reading_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
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
    a42 := JTF_VARCHAR2_TABLE_200();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
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
      a42 := JTF_VARCHAR2_TABLE_200();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).meter_id;
          a5(indx) := t(ddindx).meter_reading_id;
          a6(indx) := t(ddindx).current_reading;
          a7(indx) := t(ddindx).current_reading_date;
          a8(indx) := t(ddindx).wo_end_date;
          a9(indx) := t(ddindx).reset_flag;
          a10(indx) := t(ddindx).value_before_reset;
          a11(indx) := t(ddindx).ignore_meter_warnings;
          a12(indx) := t(ddindx).attribute_category;
          a13(indx) := t(ddindx).attribute1;
          a14(indx) := t(ddindx).attribute2;
          a15(indx) := t(ddindx).attribute3;
          a16(indx) := t(ddindx).attribute4;
          a17(indx) := t(ddindx).attribute5;
          a18(indx) := t(ddindx).attribute6;
          a19(indx) := t(ddindx).attribute7;
          a20(indx) := t(ddindx).attribute8;
          a21(indx) := t(ddindx).attribute9;
          a22(indx) := t(ddindx).attribute10;
          a23(indx) := t(ddindx).attribute11;
          a24(indx) := t(ddindx).attribute12;
          a25(indx) := t(ddindx).attribute13;
          a26(indx) := t(ddindx).attribute14;
          a27(indx) := t(ddindx).attribute15;
          a28(indx) := t(ddindx).attribute16;
          a29(indx) := t(ddindx).attribute17;
          a30(indx) := t(ddindx).attribute18;
          a31(indx) := t(ddindx).attribute19;
          a32(indx) := t(ddindx).attribute20;
          a33(indx) := t(ddindx).attribute21;
          a34(indx) := t(ddindx).attribute22;
          a35(indx) := t(ddindx).attribute23;
          a36(indx) := t(ddindx).attribute24;
          a37(indx) := t(ddindx).attribute25;
          a38(indx) := t(ddindx).attribute26;
          a39(indx) := t(ddindx).attribute27;
          a40(indx) := t(ddindx).attribute28;
          a41(indx) := t(ddindx).attribute29;
          a42(indx) := t(ddindx).attribute30;
          a43(indx) := t(ddindx).source_line_id;
          a44(indx) := t(ddindx).source_code;
          a45(indx) := t(ddindx).wo_entry_fake_flag;
          a46(indx) := t(ddindx).return_status;
          a47(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p38;

  procedure rosetta_table_copy_in_p39(t out nocopy eam_process_wo_pub.eam_counter_prop_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
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
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).counter_id := a4(indx);
          t(ddindx).property_id := a5(indx);
          t(ddindx).property_value := a6(indx);
          t(ddindx).value_timestamp := a7(indx);
          t(ddindx).migrated_flag := a8(indx);
          t(ddindx).attribute_category := a9(indx);
          t(ddindx).attribute1 := a10(indx);
          t(ddindx).attribute2 := a11(indx);
          t(ddindx).attribute3 := a12(indx);
          t(ddindx).attribute4 := a13(indx);
          t(ddindx).attribute5 := a14(indx);
          t(ddindx).attribute6 := a15(indx);
          t(ddindx).attribute7 := a16(indx);
          t(ddindx).attribute8 := a17(indx);
          t(ddindx).attribute9 := a18(indx);
          t(ddindx).attribute10 := a19(indx);
          t(ddindx).attribute11 := a20(indx);
          t(ddindx).attribute12 := a21(indx);
          t(ddindx).attribute13 := a22(indx);
          t(ddindx).attribute14 := a23(indx);
          t(ddindx).attribute15 := a24(indx);
          t(ddindx).return_status := a25(indx);
          t(ddindx).transaction_type := a26(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p39;
  procedure rosetta_table_copy_out_p39(t eam_process_wo_pub.eam_counter_prop_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
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
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
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
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).counter_id;
          a5(indx) := t(ddindx).property_id;
          a6(indx) := t(ddindx).property_value;
          a7(indx) := t(ddindx).value_timestamp;
          a8(indx) := t(ddindx).migrated_flag;
          a9(indx) := t(ddindx).attribute_category;
          a10(indx) := t(ddindx).attribute1;
          a11(indx) := t(ddindx).attribute2;
          a12(indx) := t(ddindx).attribute3;
          a13(indx) := t(ddindx).attribute4;
          a14(indx) := t(ddindx).attribute5;
          a15(indx) := t(ddindx).attribute6;
          a16(indx) := t(ddindx).attribute7;
          a17(indx) := t(ddindx).attribute8;
          a18(indx) := t(ddindx).attribute9;
          a19(indx) := t(ddindx).attribute10;
          a20(indx) := t(ddindx).attribute11;
          a21(indx) := t(ddindx).attribute12;
          a22(indx) := t(ddindx).attribute13;
          a23(indx) := t(ddindx).attribute14;
          a24(indx) := t(ddindx).attribute15;
          a25(indx) := t(ddindx).return_status;
          a26(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p39;

  procedure rosetta_table_copy_in_p40(t out nocopy eam_process_wo_pub.eam_wo_quality_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).organization_id := a4(indx);
          t(ddindx).operation_seq_number := a5(indx);
          t(ddindx).plan_id := a6(indx);
          t(ddindx).spec_id := a7(indx);
          t(ddindx).p_enable_flag := a8(indx);
          t(ddindx).element_id := a9(indx);
          t(ddindx).element_value := a10(indx);
          t(ddindx).element_validation_flag := a11(indx);
          t(ddindx).transaction_number := a12(indx);
          t(ddindx).collection_id := a13(indx);
          t(ddindx).occurrence := a14(indx);
          t(ddindx).return_status := a15(indx);
          t(ddindx).transaction_type := a16(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p40;
  procedure rosetta_table_copy_out_p40(t eam_process_wo_pub.eam_wo_quality_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
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
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).organization_id;
          a5(indx) := t(ddindx).operation_seq_number;
          a6(indx) := t(ddindx).plan_id;
          a7(indx) := t(ddindx).spec_id;
          a8(indx) := t(ddindx).p_enable_flag;
          a9(indx) := t(ddindx).element_id;
          a10(indx) := t(ddindx).element_value;
          a11(indx) := t(ddindx).element_validation_flag;
          a12(indx) := t(ddindx).transaction_number;
          a13(indx) := t(ddindx).collection_id;
          a14(indx) := t(ddindx).occurrence;
          a15(indx) := t(ddindx).return_status;
          a16(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p40;

  procedure rosetta_table_copy_in_p41(t out nocopy eam_process_wo_pub.eam_wo_comp_rebuild_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).rebuild_wip_entity_id := a4(indx);
          t(ddindx).organization_id := a5(indx);
          t(ddindx).item_removed := a6(indx);
          t(ddindx).instance_id_removed := a7(indx);
          t(ddindx).uninst_serial_removed := a8(indx);
          t(ddindx).activity_id := a9(indx);
          t(ddindx).return_status := a10(indx);
          t(ddindx).transaction_type := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p41;
  procedure rosetta_table_copy_out_p41(t eam_process_wo_pub.eam_wo_comp_rebuild_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
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
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
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
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).rebuild_wip_entity_id;
          a5(indx) := t(ddindx).organization_id;
          a6(indx) := t(ddindx).item_removed;
          a7(indx) := t(ddindx).instance_id_removed;
          a8(indx) := t(ddindx).uninst_serial_removed;
          a9(indx) := t(ddindx).activity_id;
          a10(indx) := t(ddindx).return_status;
          a11(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p41;

  procedure rosetta_table_copy_in_p42(t out nocopy eam_process_wo_pub.eam_wo_comp_mr_read_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).organization_id := a4(indx);
          t(ddindx).instance_id_issued := a5(indx);
          t(ddindx).meter_issued_serial := a6(indx);
          t(ddindx).source_meter := a7(indx);
          t(ddindx).return_status := a8(indx);
          t(ddindx).transaction_type := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p42;
  procedure rosetta_table_copy_out_p42(t eam_process_wo_pub.eam_wo_comp_mr_read_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
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
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).organization_id;
          a5(indx) := t(ddindx).instance_id_issued;
          a6(indx) := t(ddindx).meter_issued_serial;
          a7(indx) := t(ddindx).source_meter;
          a8(indx) := t(ddindx).return_status;
          a9(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p42;

  procedure rosetta_table_copy_in_p43(t out nocopy eam_process_wo_pub.eam_request_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
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
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := a0(indx);
          t(ddindx).batch_id := a1(indx);
          t(ddindx).row_id := a2(indx);
          t(ddindx).wip_entity_id := a3(indx);
          t(ddindx).wip_entity_name := a4(indx);
          t(ddindx).organization_id := a5(indx);
          t(ddindx).organization_code := a6(indx);
          t(ddindx).request_type := a7(indx);
          t(ddindx).request_id := a8(indx);
          t(ddindx).request_number := a9(indx);
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
          t(ddindx).program_id := a26(indx);
          t(ddindx).program_request_id := a27(indx);
          t(ddindx).program_update_date := a28(indx);
          t(ddindx).program_application_id := a29(indx);
          t(ddindx).work_request_status_id := a30(indx);
          t(ddindx).service_assoc_id := a31(indx);
          t(ddindx).return_status := a32(indx);
          t(ddindx).transaction_type := a33(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p43;
  procedure rosetta_table_copy_out_p43(t eam_process_wo_pub.eam_request_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
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
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
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
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).header_id;
          a1(indx) := t(ddindx).batch_id;
          a2(indx) := t(ddindx).row_id;
          a3(indx) := t(ddindx).wip_entity_id;
          a4(indx) := t(ddindx).wip_entity_name;
          a5(indx) := t(ddindx).organization_id;
          a6(indx) := t(ddindx).organization_code;
          a7(indx) := t(ddindx).request_type;
          a8(indx) := t(ddindx).request_id;
          a9(indx) := t(ddindx).request_number;
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
          a26(indx) := t(ddindx).program_id;
          a27(indx) := t(ddindx).program_request_id;
          a28(indx) := t(ddindx).program_update_date;
          a29(indx) := t(ddindx).program_application_id;
          a30(indx) := t(ddindx).work_request_status_id;
          a31(indx) := t(ddindx).service_assoc_id;
          a32(indx) := t(ddindx).return_status;
          a33(indx) := t(ddindx).transaction_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p43;

  procedure rosetta_table_copy_in_p44(t out nocopy eam_process_wo_pub.wo_relationship_exc_tbl_type, a0 JTF_VARCHAR2_TABLE_1000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p44;
  procedure rosetta_table_copy_out_p44(t eam_process_wo_pub.wo_relationship_exc_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_1000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_VARCHAR2_TABLE_1000();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p44;

  procedure rosetta_table_copy_in_p71(t out nocopy eam_process_wo_pub.eam_wo_list_type, a0 JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p71;
  procedure rosetta_table_copy_out_p71(t eam_process_wo_pub.eam_wo_list_type, a0 out nocopy JTF_VARCHAR2_TABLE_300) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p71;

end eam_process_wo_pub_w;

/
