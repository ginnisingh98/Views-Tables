--------------------------------------------------------
--  DDL for Package Body WSM_WIP_LOT_TXN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_WIP_LOT_TXN_PVT_W" as
  /* $Header: WSMVWLTB.pls 120.0 2005/07/26 23:53 nlal noship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy wsm_wip_lot_txn_pvt.wsm_job_secondary_qty_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).wip_entity_id := a0(indx);
          t(ddindx).wip_entity_name := a1(indx);
          t(ddindx).organization_id := a2(indx);
          t(ddindx).uom_code := a3(indx);
          t(ddindx).current_quantity := a4(indx);
          t(ddindx).currently_active := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t wsm_wip_lot_txn_pvt.wsm_job_secondary_qty_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).wip_entity_id;
          a1(indx) := t(ddindx).wip_entity_name;
          a2(indx) := t(ddindx).organization_id;
          a3(indx) := t(ddindx).uom_code;
          a4(indx) := t(ddindx).current_quantity;
          a5(indx) := t(ddindx).currently_active;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out nocopy wsm_wip_lot_txn_pvt.wltx_starting_jobs_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_DATE_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_DATE_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_DATE_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
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
    , a58 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).wip_entity_id := a0(indx);
          t(ddindx).wip_entity_name := a1(indx);
          t(ddindx).job_type := a2(indx);
          t(ddindx).status_type := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).representative_flag := a5(indx);
          t(ddindx).serial_track_flag := a6(indx);
          t(ddindx).class_code := a7(indx);
          t(ddindx).demand_class := a8(indx);
          t(ddindx).organization_code := a9(indx);
          t(ddindx).primary_item_id := a10(indx);
          t(ddindx).item_name := a11(indx);
          t(ddindx).organization_id := a12(indx);
          t(ddindx).intraoperation_step := a13(indx);
          t(ddindx).operation_seq_num := a14(indx);
          t(ddindx).operation_code := a15(indx);
          t(ddindx).operation_description := a16(indx);
          t(ddindx).operation_seq_id := a17(indx);
          t(ddindx).standard_operation_id := a18(indx);
          t(ddindx).department_id := a19(indx);
          t(ddindx).department_code := a20(indx);
          t(ddindx).start_quantity := a21(indx);
          t(ddindx).quantity_available := a22(indx);
          t(ddindx).net_quantity := a23(indx);
          t(ddindx).routing_reference_id := a24(indx);
          t(ddindx).bom_reference_id := a25(indx);
          t(ddindx).common_bill_sequence_id := a26(indx);
          t(ddindx).bom_revision := a27(indx);
          t(ddindx).bom_revision_date := a28(indx);
          t(ddindx).alternate_bom_designator := a29(indx);
          t(ddindx).alternate_routing_designator := a30(indx);
          t(ddindx).common_routing_sequence_id := a31(indx);
          t(ddindx).routing_revision := a32(indx);
          t(ddindx).routing_revision_date := a33(indx);
          t(ddindx).completion_subinventory := a34(indx);
          t(ddindx).completion_locator_id := a35(indx);
          t(ddindx).completion_locator := a36(indx);
          t(ddindx).date_released := a37(indx);
          t(ddindx).scheduled_start_date := a38(indx);
          t(ddindx).scheduled_completion_date := a39(indx);
          t(ddindx).coproducts_supply := a40(indx);
          t(ddindx).kanban_card_id := a41(indx);
          t(ddindx).wip_supply_type := a42(indx);
          t(ddindx).attribute_category := a43(indx);
          t(ddindx).attribute1 := a44(indx);
          t(ddindx).attribute2 := a45(indx);
          t(ddindx).attribute3 := a46(indx);
          t(ddindx).attribute4 := a47(indx);
          t(ddindx).attribute5 := a48(indx);
          t(ddindx).attribute6 := a49(indx);
          t(ddindx).attribute7 := a50(indx);
          t(ddindx).attribute8 := a51(indx);
          t(ddindx).attribute9 := a52(indx);
          t(ddindx).attribute10 := a53(indx);
          t(ddindx).attribute11 := a54(indx);
          t(ddindx).attribute12 := a55(indx);
          t(ddindx).attribute13 := a56(indx);
          t(ddindx).attribute14 := a57(indx);
          t(ddindx).attribute15 := a58(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t wsm_wip_lot_txn_pvt.wltx_starting_jobs_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_DATE_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_100();
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
    a58 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_DATE_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_100();
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
      a58 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).wip_entity_id;
          a1(indx) := t(ddindx).wip_entity_name;
          a2(indx) := t(ddindx).job_type;
          a3(indx) := t(ddindx).status_type;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).representative_flag;
          a6(indx) := t(ddindx).serial_track_flag;
          a7(indx) := t(ddindx).class_code;
          a8(indx) := t(ddindx).demand_class;
          a9(indx) := t(ddindx).organization_code;
          a10(indx) := t(ddindx).primary_item_id;
          a11(indx) := t(ddindx).item_name;
          a12(indx) := t(ddindx).organization_id;
          a13(indx) := t(ddindx).intraoperation_step;
          a14(indx) := t(ddindx).operation_seq_num;
          a15(indx) := t(ddindx).operation_code;
          a16(indx) := t(ddindx).operation_description;
          a17(indx) := t(ddindx).operation_seq_id;
          a18(indx) := t(ddindx).standard_operation_id;
          a19(indx) := t(ddindx).department_id;
          a20(indx) := t(ddindx).department_code;
          a21(indx) := t(ddindx).start_quantity;
          a22(indx) := t(ddindx).quantity_available;
          a23(indx) := t(ddindx).net_quantity;
          a24(indx) := t(ddindx).routing_reference_id;
          a25(indx) := t(ddindx).bom_reference_id;
          a26(indx) := t(ddindx).common_bill_sequence_id;
          a27(indx) := t(ddindx).bom_revision;
          a28(indx) := t(ddindx).bom_revision_date;
          a29(indx) := t(ddindx).alternate_bom_designator;
          a30(indx) := t(ddindx).alternate_routing_designator;
          a31(indx) := t(ddindx).common_routing_sequence_id;
          a32(indx) := t(ddindx).routing_revision;
          a33(indx) := t(ddindx).routing_revision_date;
          a34(indx) := t(ddindx).completion_subinventory;
          a35(indx) := t(ddindx).completion_locator_id;
          a36(indx) := t(ddindx).completion_locator;
          a37(indx) := t(ddindx).date_released;
          a38(indx) := t(ddindx).scheduled_start_date;
          a39(indx) := t(ddindx).scheduled_completion_date;
          a40(indx) := t(ddindx).coproducts_supply;
          a41(indx) := t(ddindx).kanban_card_id;
          a42(indx) := t(ddindx).wip_supply_type;
          a43(indx) := t(ddindx).attribute_category;
          a44(indx) := t(ddindx).attribute1;
          a45(indx) := t(ddindx).attribute2;
          a46(indx) := t(ddindx).attribute3;
          a47(indx) := t(ddindx).attribute4;
          a48(indx) := t(ddindx).attribute5;
          a49(indx) := t(ddindx).attribute6;
          a50(indx) := t(ddindx).attribute7;
          a51(indx) := t(ddindx).attribute8;
          a52(indx) := t(ddindx).attribute9;
          a53(indx) := t(ddindx).attribute10;
          a54(indx) := t(ddindx).attribute11;
          a55(indx) := t(ddindx).attribute12;
          a56(indx) := t(ddindx).attribute13;
          a57(indx) := t(ddindx).attribute14;
          a58(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p7(t out nocopy wsm_wip_lot_txn_pvt.wltx_resulting_jobs_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_DATE_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_100
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
    , a58 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).wip_entity_name := a0(indx);
          t(ddindx).wip_entity_id := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).job_type := a3(indx);
          t(ddindx).status_type := a4(indx);
          t(ddindx).wip_supply_type := a5(indx);
          t(ddindx).organization_id := a6(indx);
          t(ddindx).organization_code := a7(indx);
          t(ddindx).item_name := a8(indx);
          t(ddindx).primary_item_id := a9(indx);
          t(ddindx).class_code := a10(indx);
          t(ddindx).bom_reference_item := a11(indx);
          t(ddindx).bom_reference_id := a12(indx);
          t(ddindx).routing_reference_item := a13(indx);
          t(ddindx).routing_reference_id := a14(indx);
          t(ddindx).common_bom_sequence_id := a15(indx);
          t(ddindx).common_routing_sequence_id := a16(indx);
          t(ddindx).bom_revision := a17(indx);
          t(ddindx).routing_revision := a18(indx);
          t(ddindx).bom_revision_date := a19(indx);
          t(ddindx).routing_revision_date := a20(indx);
          t(ddindx).alternate_bom_designator := a21(indx);
          t(ddindx).alternate_routing_designator := a22(indx);
          t(ddindx).start_quantity := a23(indx);
          t(ddindx).net_quantity := a24(indx);
          t(ddindx).starting_operation_seq_num := a25(indx);
          t(ddindx).starting_intraoperation_step := a26(indx);
          t(ddindx).starting_operation_code := a27(indx);
          t(ddindx).starting_operation_seq_id := a28(indx);
          t(ddindx).starting_std_op_id := a29(indx);
          t(ddindx).department_id := a30(indx);
          t(ddindx).department_code := a31(indx);
          t(ddindx).operation_description := a32(indx);
          t(ddindx).job_operation_seq_num := a33(indx);
          t(ddindx).split_has_update_assy := a34(indx);
          t(ddindx).completion_subinventory := a35(indx);
          t(ddindx).completion_locator_id := a36(indx);
          t(ddindx).completion_locator := a37(indx);
          t(ddindx).scheduled_start_date := a38(indx);
          t(ddindx).scheduled_completion_date := a39(indx);
          t(ddindx).bonus_acct_id := a40(indx);
          t(ddindx).coproducts_supply := a41(indx);
          t(ddindx).kanban_card_id := a42(indx);
          t(ddindx).attribute_category := a43(indx);
          t(ddindx).attribute1 := a44(indx);
          t(ddindx).attribute2 := a45(indx);
          t(ddindx).attribute3 := a46(indx);
          t(ddindx).attribute4 := a47(indx);
          t(ddindx).attribute5 := a48(indx);
          t(ddindx).attribute6 := a49(indx);
          t(ddindx).attribute7 := a50(indx);
          t(ddindx).attribute8 := a51(indx);
          t(ddindx).attribute9 := a52(indx);
          t(ddindx).attribute10 := a53(indx);
          t(ddindx).attribute11 := a54(indx);
          t(ddindx).attribute12 := a55(indx);
          t(ddindx).attribute13 := a56(indx);
          t(ddindx).attribute14 := a57(indx);
          t(ddindx).attribute15 := a58(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t wsm_wip_lot_txn_pvt.wltx_resulting_jobs_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_VARCHAR2_TABLE_200();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_100();
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
    a58 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_VARCHAR2_TABLE_200();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_100();
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
      a58 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).wip_entity_name;
          a1(indx) := t(ddindx).wip_entity_id;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).job_type;
          a4(indx) := t(ddindx).status_type;
          a5(indx) := t(ddindx).wip_supply_type;
          a6(indx) := t(ddindx).organization_id;
          a7(indx) := t(ddindx).organization_code;
          a8(indx) := t(ddindx).item_name;
          a9(indx) := t(ddindx).primary_item_id;
          a10(indx) := t(ddindx).class_code;
          a11(indx) := t(ddindx).bom_reference_item;
          a12(indx) := t(ddindx).bom_reference_id;
          a13(indx) := t(ddindx).routing_reference_item;
          a14(indx) := t(ddindx).routing_reference_id;
          a15(indx) := t(ddindx).common_bom_sequence_id;
          a16(indx) := t(ddindx).common_routing_sequence_id;
          a17(indx) := t(ddindx).bom_revision;
          a18(indx) := t(ddindx).routing_revision;
          a19(indx) := t(ddindx).bom_revision_date;
          a20(indx) := t(ddindx).routing_revision_date;
          a21(indx) := t(ddindx).alternate_bom_designator;
          a22(indx) := t(ddindx).alternate_routing_designator;
          a23(indx) := t(ddindx).start_quantity;
          a24(indx) := t(ddindx).net_quantity;
          a25(indx) := t(ddindx).starting_operation_seq_num;
          a26(indx) := t(ddindx).starting_intraoperation_step;
          a27(indx) := t(ddindx).starting_operation_code;
          a28(indx) := t(ddindx).starting_operation_seq_id;
          a29(indx) := t(ddindx).starting_std_op_id;
          a30(indx) := t(ddindx).department_id;
          a31(indx) := t(ddindx).department_code;
          a32(indx) := t(ddindx).operation_description;
          a33(indx) := t(ddindx).job_operation_seq_num;
          a34(indx) := t(ddindx).split_has_update_assy;
          a35(indx) := t(ddindx).completion_subinventory;
          a36(indx) := t(ddindx).completion_locator_id;
          a37(indx) := t(ddindx).completion_locator;
          a38(indx) := t(ddindx).scheduled_start_date;
          a39(indx) := t(ddindx).scheduled_completion_date;
          a40(indx) := t(ddindx).bonus_acct_id;
          a41(indx) := t(ddindx).coproducts_supply;
          a42(indx) := t(ddindx).kanban_card_id;
          a43(indx) := t(ddindx).attribute_category;
          a44(indx) := t(ddindx).attribute1;
          a45(indx) := t(ddindx).attribute2;
          a46(indx) := t(ddindx).attribute3;
          a47(indx) := t(ddindx).attribute4;
          a48(indx) := t(ddindx).attribute5;
          a49(indx) := t(ddindx).attribute6;
          a50(indx) := t(ddindx).attribute7;
          a51(indx) := t(ddindx).attribute8;
          a52(indx) := t(ddindx).attribute9;
          a53(indx) := t(ddindx).attribute10;
          a54(indx) := t(ddindx).attribute11;
          a55(indx) := t(ddindx).attribute12;
          a56(indx) := t(ddindx).attribute13;
          a57(indx) := t(ddindx).attribute14;
          a58(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p8(t out nocopy wsm_serial_support_grp.wsm_serial_num_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
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
    , a33 JTF_DATE_TABLE
    , a34 JTF_DATE_TABLE
    , a35 JTF_DATE_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
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
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_200
    , a67 JTF_VARCHAR2_TABLE_200
    , a68 JTF_VARCHAR2_TABLE_200
    , a69 JTF_VARCHAR2_TABLE_200
    , a70 JTF_VARCHAR2_TABLE_200
    , a71 JTF_VARCHAR2_TABLE_200
    , a72 JTF_VARCHAR2_TABLE_200
    , a73 JTF_VARCHAR2_TABLE_200
    , a74 JTF_VARCHAR2_TABLE_200
    , a75 JTF_VARCHAR2_TABLE_200
    , a76 JTF_VARCHAR2_TABLE_200
    , a77 JTF_VARCHAR2_TABLE_200
    , a78 JTF_VARCHAR2_TABLE_200
    , a79 JTF_VARCHAR2_TABLE_200
    , a80 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).serial_number := a0(indx);
          t(ddindx).assembly_item_id := a1(indx);
          t(ddindx).header_id := a2(indx);
          t(ddindx).generate_serial_number := a3(indx);
          t(ddindx).generate_for_qty := a4(indx);
          t(ddindx).action_flag := a5(indx);
          t(ddindx).current_wip_entity_name := a6(indx);
          t(ddindx).changed_wip_entity_name := a7(indx);
          t(ddindx).current_wip_entity_id := a8(indx);
          t(ddindx).changed_wip_entity_id := a9(indx);
          t(ddindx).serial_attribute_category := a10(indx);
          t(ddindx).territory_code := a11(indx);
          t(ddindx).origination_date := a12(indx);
          t(ddindx).c_attribute1 := a13(indx);
          t(ddindx).c_attribute2 := a14(indx);
          t(ddindx).c_attribute3 := a15(indx);
          t(ddindx).c_attribute4 := a16(indx);
          t(ddindx).c_attribute5 := a17(indx);
          t(ddindx).c_attribute6 := a18(indx);
          t(ddindx).c_attribute7 := a19(indx);
          t(ddindx).c_attribute8 := a20(indx);
          t(ddindx).c_attribute9 := a21(indx);
          t(ddindx).c_attribute10 := a22(indx);
          t(ddindx).c_attribute11 := a23(indx);
          t(ddindx).c_attribute12 := a24(indx);
          t(ddindx).c_attribute13 := a25(indx);
          t(ddindx).c_attribute14 := a26(indx);
          t(ddindx).c_attribute15 := a27(indx);
          t(ddindx).c_attribute16 := a28(indx);
          t(ddindx).c_attribute17 := a29(indx);
          t(ddindx).c_attribute18 := a30(indx);
          t(ddindx).c_attribute19 := a31(indx);
          t(ddindx).c_attribute20 := a32(indx);
          t(ddindx).d_attribute1 := a33(indx);
          t(ddindx).d_attribute2 := a34(indx);
          t(ddindx).d_attribute3 := a35(indx);
          t(ddindx).d_attribute4 := a36(indx);
          t(ddindx).d_attribute5 := a37(indx);
          t(ddindx).d_attribute6 := a38(indx);
          t(ddindx).d_attribute7 := a39(indx);
          t(ddindx).d_attribute8 := a40(indx);
          t(ddindx).d_attribute9 := a41(indx);
          t(ddindx).d_attribute10 := a42(indx);
          t(ddindx).n_attribute1 := a43(indx);
          t(ddindx).n_attribute2 := a44(indx);
          t(ddindx).n_attribute3 := a45(indx);
          t(ddindx).n_attribute4 := a46(indx);
          t(ddindx).n_attribute5 := a47(indx);
          t(ddindx).n_attribute6 := a48(indx);
          t(ddindx).n_attribute7 := a49(indx);
          t(ddindx).n_attribute8 := a50(indx);
          t(ddindx).n_attribute9 := a51(indx);
          t(ddindx).n_attribute10 := a52(indx);
          t(ddindx).status_id := a53(indx);
          t(ddindx).time_since_new := a54(indx);
          t(ddindx).cycles_since_new := a55(indx);
          t(ddindx).time_since_overhaul := a56(indx);
          t(ddindx).cycles_since_overhaul := a57(indx);
          t(ddindx).time_since_repair := a58(indx);
          t(ddindx).cycles_since_repair := a59(indx);
          t(ddindx).time_since_visit := a60(indx);
          t(ddindx).cycles_since_visit := a61(indx);
          t(ddindx).time_since_mark := a62(indx);
          t(ddindx).cycles_since_mark := a63(indx);
          t(ddindx).number_of_repairs := a64(indx);
          t(ddindx).attribute_category := a65(indx);
          t(ddindx).attribute1 := a66(indx);
          t(ddindx).attribute2 := a67(indx);
          t(ddindx).attribute3 := a68(indx);
          t(ddindx).attribute4 := a69(indx);
          t(ddindx).attribute5 := a70(indx);
          t(ddindx).attribute6 := a71(indx);
          t(ddindx).attribute7 := a72(indx);
          t(ddindx).attribute8 := a73(indx);
          t(ddindx).attribute9 := a74(indx);
          t(ddindx).attribute10 := a75(indx);
          t(ddindx).attribute11 := a76(indx);
          t(ddindx).attribute12 := a77(indx);
          t(ddindx).attribute13 := a78(indx);
          t(ddindx).attribute14 := a79(indx);
          t(ddindx).attribute15 := a80(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t wsm_serial_support_grp.wsm_serial_num_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
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
    , a33 out nocopy JTF_DATE_TABLE
    , a34 out nocopy JTF_DATE_TABLE
    , a35 out nocopy JTF_DATE_TABLE
    , a36 out nocopy JTF_DATE_TABLE
    , a37 out nocopy JTF_DATE_TABLE
    , a38 out nocopy JTF_DATE_TABLE
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_DATE_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
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
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_200
    , a67 out nocopy JTF_VARCHAR2_TABLE_200
    , a68 out nocopy JTF_VARCHAR2_TABLE_200
    , a69 out nocopy JTF_VARCHAR2_TABLE_200
    , a70 out nocopy JTF_VARCHAR2_TABLE_200
    , a71 out nocopy JTF_VARCHAR2_TABLE_200
    , a72 out nocopy JTF_VARCHAR2_TABLE_200
    , a73 out nocopy JTF_VARCHAR2_TABLE_200
    , a74 out nocopy JTF_VARCHAR2_TABLE_200
    , a75 out nocopy JTF_VARCHAR2_TABLE_200
    , a76 out nocopy JTF_VARCHAR2_TABLE_200
    , a77 out nocopy JTF_VARCHAR2_TABLE_200
    , a78 out nocopy JTF_VARCHAR2_TABLE_200
    , a79 out nocopy JTF_VARCHAR2_TABLE_200
    , a80 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_300();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_DATE_TABLE();
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
    a33 := JTF_DATE_TABLE();
    a34 := JTF_DATE_TABLE();
    a35 := JTF_DATE_TABLE();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_DATE_TABLE();
    a38 := JTF_DATE_TABLE();
    a39 := JTF_DATE_TABLE();
    a40 := JTF_DATE_TABLE();
    a41 := JTF_DATE_TABLE();
    a42 := JTF_DATE_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
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
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_NUMBER_TABLE();
    a59 := JTF_NUMBER_TABLE();
    a60 := JTF_NUMBER_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_NUMBER_TABLE();
    a63 := JTF_NUMBER_TABLE();
    a64 := JTF_NUMBER_TABLE();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_200();
    a67 := JTF_VARCHAR2_TABLE_200();
    a68 := JTF_VARCHAR2_TABLE_200();
    a69 := JTF_VARCHAR2_TABLE_200();
    a70 := JTF_VARCHAR2_TABLE_200();
    a71 := JTF_VARCHAR2_TABLE_200();
    a72 := JTF_VARCHAR2_TABLE_200();
    a73 := JTF_VARCHAR2_TABLE_200();
    a74 := JTF_VARCHAR2_TABLE_200();
    a75 := JTF_VARCHAR2_TABLE_200();
    a76 := JTF_VARCHAR2_TABLE_200();
    a77 := JTF_VARCHAR2_TABLE_200();
    a78 := JTF_VARCHAR2_TABLE_200();
    a79 := JTF_VARCHAR2_TABLE_200();
    a80 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_300();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_DATE_TABLE();
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
      a33 := JTF_DATE_TABLE();
      a34 := JTF_DATE_TABLE();
      a35 := JTF_DATE_TABLE();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_DATE_TABLE();
      a38 := JTF_DATE_TABLE();
      a39 := JTF_DATE_TABLE();
      a40 := JTF_DATE_TABLE();
      a41 := JTF_DATE_TABLE();
      a42 := JTF_DATE_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
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
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_NUMBER_TABLE();
      a59 := JTF_NUMBER_TABLE();
      a60 := JTF_NUMBER_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_NUMBER_TABLE();
      a63 := JTF_NUMBER_TABLE();
      a64 := JTF_NUMBER_TABLE();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_200();
      a67 := JTF_VARCHAR2_TABLE_200();
      a68 := JTF_VARCHAR2_TABLE_200();
      a69 := JTF_VARCHAR2_TABLE_200();
      a70 := JTF_VARCHAR2_TABLE_200();
      a71 := JTF_VARCHAR2_TABLE_200();
      a72 := JTF_VARCHAR2_TABLE_200();
      a73 := JTF_VARCHAR2_TABLE_200();
      a74 := JTF_VARCHAR2_TABLE_200();
      a75 := JTF_VARCHAR2_TABLE_200();
      a76 := JTF_VARCHAR2_TABLE_200();
      a77 := JTF_VARCHAR2_TABLE_200();
      a78 := JTF_VARCHAR2_TABLE_200();
      a79 := JTF_VARCHAR2_TABLE_200();
      a80 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).serial_number;
          a1(indx) := t(ddindx).assembly_item_id;
          a2(indx) := t(ddindx).header_id;
          a3(indx) := t(ddindx).generate_serial_number;
          a4(indx) := t(ddindx).generate_for_qty;
          a5(indx) := t(ddindx).action_flag;
          a6(indx) := t(ddindx).current_wip_entity_name;
          a7(indx) := t(ddindx).changed_wip_entity_name;
          a8(indx) := t(ddindx).current_wip_entity_id;
          a9(indx) := t(ddindx).changed_wip_entity_id;
          a10(indx) := t(ddindx).serial_attribute_category;
          a11(indx) := t(ddindx).territory_code;
          a12(indx) := t(ddindx).origination_date;
          a13(indx) := t(ddindx).c_attribute1;
          a14(indx) := t(ddindx).c_attribute2;
          a15(indx) := t(ddindx).c_attribute3;
          a16(indx) := t(ddindx).c_attribute4;
          a17(indx) := t(ddindx).c_attribute5;
          a18(indx) := t(ddindx).c_attribute6;
          a19(indx) := t(ddindx).c_attribute7;
          a20(indx) := t(ddindx).c_attribute8;
          a21(indx) := t(ddindx).c_attribute9;
          a22(indx) := t(ddindx).c_attribute10;
          a23(indx) := t(ddindx).c_attribute11;
          a24(indx) := t(ddindx).c_attribute12;
          a25(indx) := t(ddindx).c_attribute13;
          a26(indx) := t(ddindx).c_attribute14;
          a27(indx) := t(ddindx).c_attribute15;
          a28(indx) := t(ddindx).c_attribute16;
          a29(indx) := t(ddindx).c_attribute17;
          a30(indx) := t(ddindx).c_attribute18;
          a31(indx) := t(ddindx).c_attribute19;
          a32(indx) := t(ddindx).c_attribute20;
          a33(indx) := t(ddindx).d_attribute1;
          a34(indx) := t(ddindx).d_attribute2;
          a35(indx) := t(ddindx).d_attribute3;
          a36(indx) := t(ddindx).d_attribute4;
          a37(indx) := t(ddindx).d_attribute5;
          a38(indx) := t(ddindx).d_attribute6;
          a39(indx) := t(ddindx).d_attribute7;
          a40(indx) := t(ddindx).d_attribute8;
          a41(indx) := t(ddindx).d_attribute9;
          a42(indx) := t(ddindx).d_attribute10;
          a43(indx) := t(ddindx).n_attribute1;
          a44(indx) := t(ddindx).n_attribute2;
          a45(indx) := t(ddindx).n_attribute3;
          a46(indx) := t(ddindx).n_attribute4;
          a47(indx) := t(ddindx).n_attribute5;
          a48(indx) := t(ddindx).n_attribute6;
          a49(indx) := t(ddindx).n_attribute7;
          a50(indx) := t(ddindx).n_attribute8;
          a51(indx) := t(ddindx).n_attribute9;
          a52(indx) := t(ddindx).n_attribute10;
          a53(indx) := t(ddindx).status_id;
          a54(indx) := t(ddindx).time_since_new;
          a55(indx) := t(ddindx).cycles_since_new;
          a56(indx) := t(ddindx).time_since_overhaul;
          a57(indx) := t(ddindx).cycles_since_overhaul;
          a58(indx) := t(ddindx).time_since_repair;
          a59(indx) := t(ddindx).cycles_since_repair;
          a60(indx) := t(ddindx).time_since_visit;
          a61(indx) := t(ddindx).cycles_since_visit;
          a62(indx) := t(ddindx).time_since_mark;
          a63(indx) := t(ddindx).cycles_since_mark;
          a64(indx) := t(ddindx).number_of_repairs;
          a65(indx) := t(ddindx).attribute_category;
          a66(indx) := t(ddindx).attribute1;
          a67(indx) := t(ddindx).attribute2;
          a68(indx) := t(ddindx).attribute3;
          a69(indx) := t(ddindx).attribute4;
          a70(indx) := t(ddindx).attribute5;
          a71(indx) := t(ddindx).attribute6;
          a72(indx) := t(ddindx).attribute7;
          a73(indx) := t(ddindx).attribute8;
          a74(indx) := t(ddindx).attribute9;
          a75(indx) := t(ddindx).attribute10;
          a76(indx) := t(ddindx).attribute11;
          a77(indx) := t(ddindx).attribute12;
          a78(indx) := t(ddindx).attribute13;
          a79(indx) := t(ddindx).attribute14;
          a80(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure invoke_txn_api(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_calling_mode  NUMBER
    , p5_a0  NUMBER
    , p5_a1  DATE
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_300
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_300
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_VARCHAR2_TABLE_100
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_VARCHAR2_TABLE_100
    , p6_a16 JTF_VARCHAR2_TABLE_300
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_VARCHAR2_TABLE_100
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_NUMBER_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_VARCHAR2_TABLE_100
    , p6_a28 JTF_DATE_TABLE
    , p6_a29 JTF_VARCHAR2_TABLE_100
    , p6_a30 JTF_VARCHAR2_TABLE_100
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_VARCHAR2_TABLE_100
    , p6_a33 JTF_DATE_TABLE
    , p6_a34 JTF_VARCHAR2_TABLE_100
    , p6_a35 JTF_NUMBER_TABLE
    , p6_a36 JTF_VARCHAR2_TABLE_200
    , p6_a37 JTF_DATE_TABLE
    , p6_a38 JTF_DATE_TABLE
    , p6_a39 JTF_DATE_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_NUMBER_TABLE
    , p6_a42 JTF_NUMBER_TABLE
    , p6_a43 JTF_VARCHAR2_TABLE_100
    , p6_a44 JTF_VARCHAR2_TABLE_200
    , p6_a45 JTF_VARCHAR2_TABLE_200
    , p6_a46 JTF_VARCHAR2_TABLE_200
    , p6_a47 JTF_VARCHAR2_TABLE_200
    , p6_a48 JTF_VARCHAR2_TABLE_200
    , p6_a49 JTF_VARCHAR2_TABLE_200
    , p6_a50 JTF_VARCHAR2_TABLE_200
    , p6_a51 JTF_VARCHAR2_TABLE_200
    , p6_a52 JTF_VARCHAR2_TABLE_200
    , p6_a53 JTF_VARCHAR2_TABLE_200
    , p6_a54 JTF_VARCHAR2_TABLE_200
    , p6_a55 JTF_VARCHAR2_TABLE_200
    , p6_a56 JTF_VARCHAR2_TABLE_200
    , p6_a57 JTF_VARCHAR2_TABLE_200
    , p6_a58 JTF_VARCHAR2_TABLE_200
    , p7_a0 JTF_VARCHAR2_TABLE_300
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_300
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_VARCHAR2_TABLE_100
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_VARCHAR2_TABLE_100
    , p7_a18 JTF_VARCHAR2_TABLE_100
    , p7_a19 JTF_DATE_TABLE
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_VARCHAR2_TABLE_100
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_VARCHAR2_TABLE_100
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_VARCHAR2_TABLE_100
    , p7_a32 JTF_VARCHAR2_TABLE_300
    , p7_a33 JTF_NUMBER_TABLE
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_NUMBER_TABLE
    , p7_a37 JTF_VARCHAR2_TABLE_200
    , p7_a38 JTF_DATE_TABLE
    , p7_a39 JTF_DATE_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_NUMBER_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_VARCHAR2_TABLE_100
    , p7_a44 JTF_VARCHAR2_TABLE_200
    , p7_a45 JTF_VARCHAR2_TABLE_200
    , p7_a46 JTF_VARCHAR2_TABLE_200
    , p7_a47 JTF_VARCHAR2_TABLE_200
    , p7_a48 JTF_VARCHAR2_TABLE_200
    , p7_a49 JTF_VARCHAR2_TABLE_200
    , p7_a50 JTF_VARCHAR2_TABLE_200
    , p7_a51 JTF_VARCHAR2_TABLE_200
    , p7_a52 JTF_VARCHAR2_TABLE_200
    , p7_a53 JTF_VARCHAR2_TABLE_200
    , p7_a54 JTF_VARCHAR2_TABLE_200
    , p7_a55 JTF_VARCHAR2_TABLE_200
    , p7_a56 JTF_VARCHAR2_TABLE_200
    , p7_a57 JTF_VARCHAR2_TABLE_200
    , p7_a58 JTF_VARCHAR2_TABLE_200
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_VARCHAR2_TABLE_300
    , p8_a7 JTF_VARCHAR2_TABLE_300
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_NUMBER_TABLE
    , p8_a10 JTF_VARCHAR2_TABLE_100
    , p8_a11 JTF_VARCHAR2_TABLE_100
    , p8_a12 JTF_DATE_TABLE
    , p8_a13 JTF_VARCHAR2_TABLE_200
    , p8_a14 JTF_VARCHAR2_TABLE_200
    , p8_a15 JTF_VARCHAR2_TABLE_200
    , p8_a16 JTF_VARCHAR2_TABLE_200
    , p8_a17 JTF_VARCHAR2_TABLE_200
    , p8_a18 JTF_VARCHAR2_TABLE_200
    , p8_a19 JTF_VARCHAR2_TABLE_200
    , p8_a20 JTF_VARCHAR2_TABLE_200
    , p8_a21 JTF_VARCHAR2_TABLE_200
    , p8_a22 JTF_VARCHAR2_TABLE_200
    , p8_a23 JTF_VARCHAR2_TABLE_200
    , p8_a24 JTF_VARCHAR2_TABLE_200
    , p8_a25 JTF_VARCHAR2_TABLE_200
    , p8_a26 JTF_VARCHAR2_TABLE_200
    , p8_a27 JTF_VARCHAR2_TABLE_200
    , p8_a28 JTF_VARCHAR2_TABLE_200
    , p8_a29 JTF_VARCHAR2_TABLE_200
    , p8_a30 JTF_VARCHAR2_TABLE_200
    , p8_a31 JTF_VARCHAR2_TABLE_200
    , p8_a32 JTF_VARCHAR2_TABLE_200
    , p8_a33 JTF_DATE_TABLE
    , p8_a34 JTF_DATE_TABLE
    , p8_a35 JTF_DATE_TABLE
    , p8_a36 JTF_DATE_TABLE
    , p8_a37 JTF_DATE_TABLE
    , p8_a38 JTF_DATE_TABLE
    , p8_a39 JTF_DATE_TABLE
    , p8_a40 JTF_DATE_TABLE
    , p8_a41 JTF_DATE_TABLE
    , p8_a42 JTF_DATE_TABLE
    , p8_a43 JTF_NUMBER_TABLE
    , p8_a44 JTF_NUMBER_TABLE
    , p8_a45 JTF_NUMBER_TABLE
    , p8_a46 JTF_NUMBER_TABLE
    , p8_a47 JTF_NUMBER_TABLE
    , p8_a48 JTF_NUMBER_TABLE
    , p8_a49 JTF_NUMBER_TABLE
    , p8_a50 JTF_NUMBER_TABLE
    , p8_a51 JTF_NUMBER_TABLE
    , p8_a52 JTF_NUMBER_TABLE
    , p8_a53 JTF_NUMBER_TABLE
    , p8_a54 JTF_NUMBER_TABLE
    , p8_a55 JTF_NUMBER_TABLE
    , p8_a56 JTF_NUMBER_TABLE
    , p8_a57 JTF_NUMBER_TABLE
    , p8_a58 JTF_NUMBER_TABLE
    , p8_a59 JTF_NUMBER_TABLE
    , p8_a60 JTF_NUMBER_TABLE
    , p8_a61 JTF_NUMBER_TABLE
    , p8_a62 JTF_NUMBER_TABLE
    , p8_a63 JTF_NUMBER_TABLE
    , p8_a64 JTF_NUMBER_TABLE
    , p8_a65 JTF_VARCHAR2_TABLE_100
    , p8_a66 JTF_VARCHAR2_TABLE_200
    , p8_a67 JTF_VARCHAR2_TABLE_200
    , p8_a68 JTF_VARCHAR2_TABLE_200
    , p8_a69 JTF_VARCHAR2_TABLE_200
    , p8_a70 JTF_VARCHAR2_TABLE_200
    , p8_a71 JTF_VARCHAR2_TABLE_200
    , p8_a72 JTF_VARCHAR2_TABLE_200
    , p8_a73 JTF_VARCHAR2_TABLE_200
    , p8_a74 JTF_VARCHAR2_TABLE_200
    , p8_a75 JTF_VARCHAR2_TABLE_200
    , p8_a76 JTF_VARCHAR2_TABLE_200
    , p8_a77 JTF_VARCHAR2_TABLE_200
    , p8_a78 JTF_VARCHAR2_TABLE_200
    , p8_a79 JTF_VARCHAR2_TABLE_200
    , p8_a80 JTF_VARCHAR2_TABLE_200
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_300
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_VARCHAR2_TABLE_100
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_error_msg out nocopy  VARCHAR2
  )

  as
    ddp_txn_header_rec wsm_wip_lot_txn_pvt.wltx_transactions_rec_type;
    ddp_starting_jobs_tbl wsm_wip_lot_txn_pvt.wltx_starting_jobs_tbl_type;
    ddp_resulting_jobs_tbl wsm_wip_lot_txn_pvt.wltx_resulting_jobs_tbl_type;
    ddp_wsm_serial_num_tbl wsm_serial_support_grp.wsm_serial_num_tbl;
    ddp_secondary_qty_tbl wsm_wip_lot_txn_pvt.wsm_job_secondary_qty_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_txn_header_rec.transaction_type_id := p5_a0;
    ddp_txn_header_rec.transaction_date := p5_a1;
    ddp_txn_header_rec.transaction_reference := p5_a2;
    ddp_txn_header_rec.reason_id := p5_a3;
    ddp_txn_header_rec.transaction_id := p5_a4;
    ddp_txn_header_rec.employee_id := p5_a5;
    ddp_txn_header_rec.organization_code := p5_a6;
    ddp_txn_header_rec.organization_id := p5_a7;
    ddp_txn_header_rec.error_message := p5_a8;
    ddp_txn_header_rec.attribute_category := p5_a9;
    ddp_txn_header_rec.attribute1 := p5_a10;
    ddp_txn_header_rec.attribute2 := p5_a11;
    ddp_txn_header_rec.attribute3 := p5_a12;
    ddp_txn_header_rec.attribute4 := p5_a13;
    ddp_txn_header_rec.attribute5 := p5_a14;
    ddp_txn_header_rec.attribute6 := p5_a15;
    ddp_txn_header_rec.attribute7 := p5_a16;
    ddp_txn_header_rec.attribute8 := p5_a17;
    ddp_txn_header_rec.attribute9 := p5_a18;
    ddp_txn_header_rec.attribute10 := p5_a19;
    ddp_txn_header_rec.attribute11 := p5_a20;
    ddp_txn_header_rec.attribute12 := p5_a21;
    ddp_txn_header_rec.attribute13 := p5_a22;
    ddp_txn_header_rec.attribute14 := p5_a23;
    ddp_txn_header_rec.attribute15 := p5_a24;

    wsm_wip_lot_txn_pvt_w.rosetta_table_copy_in_p6(ddp_starting_jobs_tbl, p6_a0
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
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      );

    wsm_wip_lot_txn_pvt_w.rosetta_table_copy_in_p7(ddp_resulting_jobs_tbl, p7_a0
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
      );

    wsm_wip_lot_txn_pvt_w.rosetta_table_copy_in_p8(ddp_wsm_serial_num_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      , p8_a64
      , p8_a65
      , p8_a66
      , p8_a67
      , p8_a68
      , p8_a69
      , p8_a70
      , p8_a71
      , p8_a72
      , p8_a73
      , p8_a74
      , p8_a75
      , p8_a76
      , p8_a77
      , p8_a78
      , p8_a79
      , p8_a80
      );

    wsm_wip_lot_txn_pvt_w.rosetta_table_copy_in_p5(ddp_secondary_qty_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      );




    -- here's the delegated call to the old PL/SQL routine
    wsm_wip_lot_txn_pvt.invoke_txn_api(p_api_version,
      p_commit,
      p_validation_level,
      p_init_msg_list,
      p_calling_mode,
      ddp_txn_header_rec,
      ddp_starting_jobs_tbl,
      ddp_resulting_jobs_tbl,
      ddp_wsm_serial_num_tbl,
      ddp_secondary_qty_tbl,
      x_return_status,
      x_msg_count,
      x_error_msg);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

end wsm_wip_lot_txn_pvt_w;

/
