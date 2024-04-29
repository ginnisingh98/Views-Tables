--------------------------------------------------------
--  DDL for Package Body CSF_DEBRIEF_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DEBRIEF_PUB_W" as
  /* $Header: csfrwdbb.pls 120.0 2005/05/24 18:28:05 appldev noship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy csf_debrief_pub.debrief_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).debrief_header_id := a0(indx);
          t(ddindx).debrief_number := a1(indx);
          t(ddindx).debrief_date := a2(indx);
          t(ddindx).debrief_status_id := a3(indx);
          t(ddindx).task_assignment_id := a4(indx);
          t(ddindx).created_by := a5(indx);
          t(ddindx).creation_date := a6(indx);
          t(ddindx).last_updated_by := a7(indx);
          t(ddindx).last_update_date := a8(indx);
          t(ddindx).last_update_login := a9(indx);
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
          t(ddindx).attribute_category := a25(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t csf_debrief_pub.debrief_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).debrief_header_id;
          a1(indx) := t(ddindx).debrief_number;
          a2(indx) := t(ddindx).debrief_date;
          a3(indx) := t(ddindx).debrief_status_id;
          a4(indx) := t(ddindx).task_assignment_id;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := t(ddindx).last_updated_by;
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := t(ddindx).last_update_login;
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
          a25(indx) := t(ddindx).attribute_category;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p10(t out nocopy csf_debrief_pub.debrief_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_DATE_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_DATE_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_DATE_TABLE
    , a48 JTF_NUMBER_TABLE
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
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_200
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).debrief_line_id := a0(indx);
          t(ddindx).debrief_header_id := a1(indx);
          t(ddindx).debrief_line_number := a2(indx);
          t(ddindx).service_date := a3(indx);
          t(ddindx).business_process_id := a4(indx);
          t(ddindx).txn_billing_type_id := a5(indx);
          t(ddindx).inventory_item_id := a6(indx);
          t(ddindx).instance_id := a7(indx);
          t(ddindx).issuing_inventory_org_id := a8(indx);
          t(ddindx).receiving_inventory_org_id := a9(indx);
          t(ddindx).issuing_sub_inventory_code := a10(indx);
          t(ddindx).receiving_sub_inventory_code := a11(indx);
          t(ddindx).issuing_locator_id := a12(indx);
          t(ddindx).receiving_locator_id := a13(indx);
          t(ddindx).parent_product_id := a14(indx);
          t(ddindx).removed_product_id := a15(indx);
          t(ddindx).status_of_received_part := a16(indx);
          t(ddindx).item_serial_number := a17(indx);
          t(ddindx).item_revision := a18(indx);
          t(ddindx).item_lotnumber := a19(indx);
          t(ddindx).uom_code := a20(indx);
          t(ddindx).quantity := a21(indx);
          t(ddindx).rma_header_id := a22(indx);
          t(ddindx).disposition_code := a23(indx);
          t(ddindx).material_reason_code := a24(indx);
          t(ddindx).labor_reason_code := a25(indx);
          t(ddindx).expense_reason_code := a26(indx);
          t(ddindx).labor_start_date := a27(indx);
          t(ddindx).labor_end_date := a28(indx);
          t(ddindx).starting_mileage := a29(indx);
          t(ddindx).ending_mileage := a30(indx);
          t(ddindx).expense_amount := a31(indx);
          t(ddindx).currency_code := a32(indx);
          t(ddindx).debrief_line_status_id := a33(indx);
          t(ddindx).channel_code := a34(indx);
          t(ddindx).charge_upload_status := a35(indx);
          t(ddindx).charge_upload_msg_code := a36(indx);
          t(ddindx).charge_upload_message := a37(indx);
          t(ddindx).ib_update_status := a38(indx);
          t(ddindx).ib_update_msg_code := a39(indx);
          t(ddindx).ib_update_message := a40(indx);
          t(ddindx).spare_update_status := a41(indx);
          t(ddindx).spare_update_msg_code := a42(indx);
          t(ddindx).spare_update_message := a43(indx);
          t(ddindx).created_by := a44(indx);
          t(ddindx).creation_date := a45(indx);
          t(ddindx).last_updated_by := a46(indx);
          t(ddindx).last_update_date := a47(indx);
          t(ddindx).last_update_login := a48(indx);
          t(ddindx).attribute1 := a49(indx);
          t(ddindx).attribute2 := a50(indx);
          t(ddindx).attribute3 := a51(indx);
          t(ddindx).attribute4 := a52(indx);
          t(ddindx).attribute5 := a53(indx);
          t(ddindx).attribute6 := a54(indx);
          t(ddindx).attribute7 := a55(indx);
          t(ddindx).attribute8 := a56(indx);
          t(ddindx).attribute9 := a57(indx);
          t(ddindx).attribute10 := a58(indx);
          t(ddindx).attribute11 := a59(indx);
          t(ddindx).attribute12 := a60(indx);
          t(ddindx).attribute13 := a61(indx);
          t(ddindx).attribute14 := a62(indx);
          t(ddindx).attribute15 := a63(indx);
          t(ddindx).attribute_category := a64(indx);
          t(ddindx).return_reason_code := a65(indx);
          t(ddindx).transaction_type_id := a66(indx);
          t(ddindx).return_date := a67(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t csf_debrief_pub.debrief_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_DATE_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_DATE_TABLE
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_DATE_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
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
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_200
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_DATE_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_300();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_VARCHAR2_TABLE_100();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_DATE_TABLE();
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_DATE_TABLE();
    a48 := JTF_NUMBER_TABLE();
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
    a59 := JTF_VARCHAR2_TABLE_200();
    a60 := JTF_VARCHAR2_TABLE_200();
    a61 := JTF_VARCHAR2_TABLE_200();
    a62 := JTF_VARCHAR2_TABLE_200();
    a63 := JTF_VARCHAR2_TABLE_200();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_NUMBER_TABLE();
    a67 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_DATE_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_300();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_VARCHAR2_TABLE_100();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_DATE_TABLE();
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_DATE_TABLE();
      a48 := JTF_NUMBER_TABLE();
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
      a59 := JTF_VARCHAR2_TABLE_200();
      a60 := JTF_VARCHAR2_TABLE_200();
      a61 := JTF_VARCHAR2_TABLE_200();
      a62 := JTF_VARCHAR2_TABLE_200();
      a63 := JTF_VARCHAR2_TABLE_200();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_NUMBER_TABLE();
      a67 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).debrief_line_id;
          a1(indx) := t(ddindx).debrief_header_id;
          a2(indx) := t(ddindx).debrief_line_number;
          a3(indx) := t(ddindx).service_date;
          a4(indx) := t(ddindx).business_process_id;
          a5(indx) := t(ddindx).txn_billing_type_id;
          a6(indx) := t(ddindx).inventory_item_id;
          a7(indx) := t(ddindx).instance_id;
          a8(indx) := t(ddindx).issuing_inventory_org_id;
          a9(indx) := t(ddindx).receiving_inventory_org_id;
          a10(indx) := t(ddindx).issuing_sub_inventory_code;
          a11(indx) := t(ddindx).receiving_sub_inventory_code;
          a12(indx) := t(ddindx).issuing_locator_id;
          a13(indx) := t(ddindx).receiving_locator_id;
          a14(indx) := t(ddindx).parent_product_id;
          a15(indx) := t(ddindx).removed_product_id;
          a16(indx) := t(ddindx).status_of_received_part;
          a17(indx) := t(ddindx).item_serial_number;
          a18(indx) := t(ddindx).item_revision;
          a19(indx) := t(ddindx).item_lotnumber;
          a20(indx) := t(ddindx).uom_code;
          a21(indx) := t(ddindx).quantity;
          a22(indx) := t(ddindx).rma_header_id;
          a23(indx) := t(ddindx).disposition_code;
          a24(indx) := t(ddindx).material_reason_code;
          a25(indx) := t(ddindx).labor_reason_code;
          a26(indx) := t(ddindx).expense_reason_code;
          a27(indx) := t(ddindx).labor_start_date;
          a28(indx) := t(ddindx).labor_end_date;
          a29(indx) := t(ddindx).starting_mileage;
          a30(indx) := t(ddindx).ending_mileage;
          a31(indx) := t(ddindx).expense_amount;
          a32(indx) := t(ddindx).currency_code;
          a33(indx) := t(ddindx).debrief_line_status_id;
          a34(indx) := t(ddindx).channel_code;
          a35(indx) := t(ddindx).charge_upload_status;
          a36(indx) := t(ddindx).charge_upload_msg_code;
          a37(indx) := t(ddindx).charge_upload_message;
          a38(indx) := t(ddindx).ib_update_status;
          a39(indx) := t(ddindx).ib_update_msg_code;
          a40(indx) := t(ddindx).ib_update_message;
          a41(indx) := t(ddindx).spare_update_status;
          a42(indx) := t(ddindx).spare_update_msg_code;
          a43(indx) := t(ddindx).spare_update_message;
          a44(indx) := t(ddindx).created_by;
          a45(indx) := t(ddindx).creation_date;
          a46(indx) := t(ddindx).last_updated_by;
          a47(indx) := t(ddindx).last_update_date;
          a48(indx) := t(ddindx).last_update_login;
          a49(indx) := t(ddindx).attribute1;
          a50(indx) := t(ddindx).attribute2;
          a51(indx) := t(ddindx).attribute3;
          a52(indx) := t(ddindx).attribute4;
          a53(indx) := t(ddindx).attribute5;
          a54(indx) := t(ddindx).attribute6;
          a55(indx) := t(ddindx).attribute7;
          a56(indx) := t(ddindx).attribute8;
          a57(indx) := t(ddindx).attribute9;
          a58(indx) := t(ddindx).attribute10;
          a59(indx) := t(ddindx).attribute11;
          a60(indx) := t(ddindx).attribute12;
          a61(indx) := t(ddindx).attribute13;
          a62(indx) := t(ddindx).attribute14;
          a63(indx) := t(ddindx).attribute15;
          a64(indx) := t(ddindx).attribute_category;
          a65(indx) := t(ddindx).return_reason_code;
          a66(indx) := t(ddindx).transaction_type_id;
          a67(indx) := t(ddindx).return_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure create_debrief(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
    , p3_a2  DATE
    , p3_a3  NUMBER
    , p3_a4  NUMBER
    , p3_a5  NUMBER
    , p3_a6  DATE
    , p3_a7  NUMBER
    , p3_a8  DATE
    , p3_a9  NUMBER
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_DATE_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_NUMBER_TABLE
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_NUMBER_TABLE
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_VARCHAR2_TABLE_100
    , p4_a17 JTF_VARCHAR2_TABLE_100
    , p4_a18 JTF_VARCHAR2_TABLE_100
    , p4_a19 JTF_VARCHAR2_TABLE_100
    , p4_a20 JTF_VARCHAR2_TABLE_100
    , p4_a21 JTF_NUMBER_TABLE
    , p4_a22 JTF_NUMBER_TABLE
    , p4_a23 JTF_VARCHAR2_TABLE_100
    , p4_a24 JTF_VARCHAR2_TABLE_100
    , p4_a25 JTF_VARCHAR2_TABLE_100
    , p4_a26 JTF_VARCHAR2_TABLE_100
    , p4_a27 JTF_DATE_TABLE
    , p4_a28 JTF_DATE_TABLE
    , p4_a29 JTF_NUMBER_TABLE
    , p4_a30 JTF_NUMBER_TABLE
    , p4_a31 JTF_NUMBER_TABLE
    , p4_a32 JTF_VARCHAR2_TABLE_100
    , p4_a33 JTF_NUMBER_TABLE
    , p4_a34 JTF_VARCHAR2_TABLE_100
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_100
    , p4_a37 JTF_VARCHAR2_TABLE_300
    , p4_a38 JTF_VARCHAR2_TABLE_100
    , p4_a39 JTF_VARCHAR2_TABLE_100
    , p4_a40 JTF_VARCHAR2_TABLE_300
    , p4_a41 JTF_VARCHAR2_TABLE_100
    , p4_a42 JTF_VARCHAR2_TABLE_100
    , p4_a43 JTF_VARCHAR2_TABLE_300
    , p4_a44 JTF_NUMBER_TABLE
    , p4_a45 JTF_DATE_TABLE
    , p4_a46 JTF_NUMBER_TABLE
    , p4_a47 JTF_DATE_TABLE
    , p4_a48 JTF_NUMBER_TABLE
    , p4_a49 JTF_VARCHAR2_TABLE_200
    , p4_a50 JTF_VARCHAR2_TABLE_200
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_200
    , p4_a53 JTF_VARCHAR2_TABLE_200
    , p4_a54 JTF_VARCHAR2_TABLE_200
    , p4_a55 JTF_VARCHAR2_TABLE_200
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_200
    , p4_a58 JTF_VARCHAR2_TABLE_200
    , p4_a59 JTF_VARCHAR2_TABLE_200
    , p4_a60 JTF_VARCHAR2_TABLE_200
    , p4_a61 JTF_VARCHAR2_TABLE_200
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_200
    , p4_a64 JTF_VARCHAR2_TABLE_100
    , p4_a65 JTF_VARCHAR2_TABLE_100
    , p4_a66 JTF_NUMBER_TABLE
    , p4_a67 JTF_DATE_TABLE
    , x_debrief_header_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_debrief_rec csf_debrief_pub.debrief_rec_type;
    ddp_debrief_line_tbl csf_debrief_pub.debrief_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_debrief_rec.debrief_header_id := p3_a0;
    ddp_debrief_rec.debrief_number := p3_a1;
    ddp_debrief_rec.debrief_date := p3_a2;
    ddp_debrief_rec.debrief_status_id := p3_a3;
    ddp_debrief_rec.task_assignment_id := p3_a4;
    ddp_debrief_rec.created_by := p3_a5;
    ddp_debrief_rec.creation_date := p3_a6;
    ddp_debrief_rec.last_updated_by := p3_a7;
    ddp_debrief_rec.last_update_date := p3_a8;
    ddp_debrief_rec.last_update_login := p3_a9;
    ddp_debrief_rec.attribute1 := p3_a10;
    ddp_debrief_rec.attribute2 := p3_a11;
    ddp_debrief_rec.attribute3 := p3_a12;
    ddp_debrief_rec.attribute4 := p3_a13;
    ddp_debrief_rec.attribute5 := p3_a14;
    ddp_debrief_rec.attribute6 := p3_a15;
    ddp_debrief_rec.attribute7 := p3_a16;
    ddp_debrief_rec.attribute8 := p3_a17;
    ddp_debrief_rec.attribute9 := p3_a18;
    ddp_debrief_rec.attribute10 := p3_a19;
    ddp_debrief_rec.attribute11 := p3_a20;
    ddp_debrief_rec.attribute12 := p3_a21;
    ddp_debrief_rec.attribute13 := p3_a22;
    ddp_debrief_rec.attribute14 := p3_a23;
    ddp_debrief_rec.attribute15 := p3_a24;
    ddp_debrief_rec.attribute_category := p3_a25;

    csf_debrief_pub_w.rosetta_table_copy_in_p10(ddp_debrief_line_tbl, p4_a0
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
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      , p4_a48
      , p4_a49
      , p4_a50
      , p4_a51
      , p4_a52
      , p4_a53
      , p4_a54
      , p4_a55
      , p4_a56
      , p4_a57
      , p4_a58
      , p4_a59
      , p4_a60
      , p4_a61
      , p4_a62
      , p4_a63
      , p4_a64
      , p4_a65
      , p4_a66
      , p4_a67
      );





    -- here's the delegated call to the old PL/SQL routine
    csf_debrief_pub.create_debrief(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_debrief_rec,
      ddp_debrief_line_tbl,
      x_debrief_header_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_debrief(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
    , p3_a2  DATE
    , p3_a3  NUMBER
    , p3_a4  NUMBER
    , p3_a5  NUMBER
    , p3_a6  DATE
    , p3_a7  NUMBER
    , p3_a8  DATE
    , p3_a9  NUMBER
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_debrief_rec csf_debrief_pub.debrief_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_debrief_rec.debrief_header_id := p3_a0;
    ddp_debrief_rec.debrief_number := p3_a1;
    ddp_debrief_rec.debrief_date := p3_a2;
    ddp_debrief_rec.debrief_status_id := p3_a3;
    ddp_debrief_rec.task_assignment_id := p3_a4;
    ddp_debrief_rec.created_by := p3_a5;
    ddp_debrief_rec.creation_date := p3_a6;
    ddp_debrief_rec.last_updated_by := p3_a7;
    ddp_debrief_rec.last_update_date := p3_a8;
    ddp_debrief_rec.last_update_login := p3_a9;
    ddp_debrief_rec.attribute1 := p3_a10;
    ddp_debrief_rec.attribute2 := p3_a11;
    ddp_debrief_rec.attribute3 := p3_a12;
    ddp_debrief_rec.attribute4 := p3_a13;
    ddp_debrief_rec.attribute5 := p3_a14;
    ddp_debrief_rec.attribute6 := p3_a15;
    ddp_debrief_rec.attribute7 := p3_a16;
    ddp_debrief_rec.attribute8 := p3_a17;
    ddp_debrief_rec.attribute9 := p3_a18;
    ddp_debrief_rec.attribute10 := p3_a19;
    ddp_debrief_rec.attribute11 := p3_a20;
    ddp_debrief_rec.attribute12 := p3_a21;
    ddp_debrief_rec.attribute13 := p3_a22;
    ddp_debrief_rec.attribute14 := p3_a23;
    ddp_debrief_rec.attribute15 := p3_a24;
    ddp_debrief_rec.attribute_category := p3_a25;




    -- here's the delegated call to the old PL/SQL routine
    csf_debrief_pub.update_debrief(p_api_version_number,
      p_init_msg_list,
      p_commit,
      ddp_debrief_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_debrief_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_upd_tskassgnstatus  VARCHAR2
    , p_task_assignment_status  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_100
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_DATE_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_VARCHAR2_TABLE_300
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_300
    , p5_a41 JTF_VARCHAR2_TABLE_100
    , p5_a42 JTF_VARCHAR2_TABLE_100
    , p5_a43 JTF_VARCHAR2_TABLE_300
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_DATE_TABLE
    , p5_a46 JTF_NUMBER_TABLE
    , p5_a47 JTF_DATE_TABLE
    , p5_a48 JTF_NUMBER_TABLE
    , p5_a49 JTF_VARCHAR2_TABLE_200
    , p5_a50 JTF_VARCHAR2_TABLE_200
    , p5_a51 JTF_VARCHAR2_TABLE_200
    , p5_a52 JTF_VARCHAR2_TABLE_200
    , p5_a53 JTF_VARCHAR2_TABLE_200
    , p5_a54 JTF_VARCHAR2_TABLE_200
    , p5_a55 JTF_VARCHAR2_TABLE_200
    , p5_a56 JTF_VARCHAR2_TABLE_200
    , p5_a57 JTF_VARCHAR2_TABLE_200
    , p5_a58 JTF_VARCHAR2_TABLE_200
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
    , p5_a63 JTF_VARCHAR2_TABLE_200
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_NUMBER_TABLE
    , p5_a67 JTF_DATE_TABLE
    , p_debrief_header_id  NUMBER
    , p_source_object_type_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_debrief_line_tbl csf_debrief_pub.debrief_line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    csf_debrief_pub_w.rosetta_table_copy_in_p10(ddp_debrief_line_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      );






    -- here's the delegated call to the old PL/SQL routine
    csf_debrief_pub.create_debrief_lines(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_upd_tskassgnstatus,
      p_task_assignment_status,
      ddp_debrief_line_tbl,
      p_debrief_header_id,
      p_source_object_type_code,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_debrief_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_upd_tskassgnstatus  VARCHAR2
    , p_task_assignment_status  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  DATE
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  DATE
    , p5_a28  DATE
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  NUMBER
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  NUMBER
    , p5_a45  DATE
    , p5_a46  NUMBER
    , p5_a47  DATE
    , p5_a48  NUMBER
    , p5_a49  VARCHAR2
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p5_a54  VARCHAR2
    , p5_a55  VARCHAR2
    , p5_a56  VARCHAR2
    , p5_a57  VARCHAR2
    , p5_a58  VARCHAR2
    , p5_a59  VARCHAR2
    , p5_a60  VARCHAR2
    , p5_a61  VARCHAR2
    , p5_a62  VARCHAR2
    , p5_a63  VARCHAR2
    , p5_a64  VARCHAR2
    , p5_a65  VARCHAR2
    , p5_a66  NUMBER
    , p5_a67  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_debrief_line_rec csf_debrief_pub.debrief_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_debrief_line_rec.debrief_line_id := p5_a0;
    ddp_debrief_line_rec.debrief_header_id := p5_a1;
    ddp_debrief_line_rec.debrief_line_number := p5_a2;
    ddp_debrief_line_rec.service_date := p5_a3;
    ddp_debrief_line_rec.business_process_id := p5_a4;
    ddp_debrief_line_rec.txn_billing_type_id := p5_a5;
    ddp_debrief_line_rec.inventory_item_id := p5_a6;
    ddp_debrief_line_rec.instance_id := p5_a7;
    ddp_debrief_line_rec.issuing_inventory_org_id := p5_a8;
    ddp_debrief_line_rec.receiving_inventory_org_id := p5_a9;
    ddp_debrief_line_rec.issuing_sub_inventory_code := p5_a10;
    ddp_debrief_line_rec.receiving_sub_inventory_code := p5_a11;
    ddp_debrief_line_rec.issuing_locator_id := p5_a12;
    ddp_debrief_line_rec.receiving_locator_id := p5_a13;
    ddp_debrief_line_rec.parent_product_id := p5_a14;
    ddp_debrief_line_rec.removed_product_id := p5_a15;
    ddp_debrief_line_rec.status_of_received_part := p5_a16;
    ddp_debrief_line_rec.item_serial_number := p5_a17;
    ddp_debrief_line_rec.item_revision := p5_a18;
    ddp_debrief_line_rec.item_lotnumber := p5_a19;
    ddp_debrief_line_rec.uom_code := p5_a20;
    ddp_debrief_line_rec.quantity := p5_a21;
    ddp_debrief_line_rec.rma_header_id := p5_a22;
    ddp_debrief_line_rec.disposition_code := p5_a23;
    ddp_debrief_line_rec.material_reason_code := p5_a24;
    ddp_debrief_line_rec.labor_reason_code := p5_a25;
    ddp_debrief_line_rec.expense_reason_code := p5_a26;
    ddp_debrief_line_rec.labor_start_date := p5_a27;
    ddp_debrief_line_rec.labor_end_date := p5_a28;
    ddp_debrief_line_rec.starting_mileage := p5_a29;
    ddp_debrief_line_rec.ending_mileage := p5_a30;
    ddp_debrief_line_rec.expense_amount := p5_a31;
    ddp_debrief_line_rec.currency_code := p5_a32;
    ddp_debrief_line_rec.debrief_line_status_id := p5_a33;
    ddp_debrief_line_rec.channel_code := p5_a34;
    ddp_debrief_line_rec.charge_upload_status := p5_a35;
    ddp_debrief_line_rec.charge_upload_msg_code := p5_a36;
    ddp_debrief_line_rec.charge_upload_message := p5_a37;
    ddp_debrief_line_rec.ib_update_status := p5_a38;
    ddp_debrief_line_rec.ib_update_msg_code := p5_a39;
    ddp_debrief_line_rec.ib_update_message := p5_a40;
    ddp_debrief_line_rec.spare_update_status := p5_a41;
    ddp_debrief_line_rec.spare_update_msg_code := p5_a42;
    ddp_debrief_line_rec.spare_update_message := p5_a43;
    ddp_debrief_line_rec.created_by := p5_a44;
    ddp_debrief_line_rec.creation_date := p5_a45;
    ddp_debrief_line_rec.last_updated_by := p5_a46;
    ddp_debrief_line_rec.last_update_date := p5_a47;
    ddp_debrief_line_rec.last_update_login := p5_a48;
    ddp_debrief_line_rec.attribute1 := p5_a49;
    ddp_debrief_line_rec.attribute2 := p5_a50;
    ddp_debrief_line_rec.attribute3 := p5_a51;
    ddp_debrief_line_rec.attribute4 := p5_a52;
    ddp_debrief_line_rec.attribute5 := p5_a53;
    ddp_debrief_line_rec.attribute6 := p5_a54;
    ddp_debrief_line_rec.attribute7 := p5_a55;
    ddp_debrief_line_rec.attribute8 := p5_a56;
    ddp_debrief_line_rec.attribute9 := p5_a57;
    ddp_debrief_line_rec.attribute10 := p5_a58;
    ddp_debrief_line_rec.attribute11 := p5_a59;
    ddp_debrief_line_rec.attribute12 := p5_a60;
    ddp_debrief_line_rec.attribute13 := p5_a61;
    ddp_debrief_line_rec.attribute14 := p5_a62;
    ddp_debrief_line_rec.attribute15 := p5_a63;
    ddp_debrief_line_rec.attribute_category := p5_a64;
    ddp_debrief_line_rec.return_reason_code := p5_a65;
    ddp_debrief_line_rec.transaction_type_id := p5_a66;
    ddp_debrief_line_rec.return_date := p5_a67;




    -- here's the delegated call to the old PL/SQL routine
    csf_debrief_pub.update_debrief_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_upd_tskassgnstatus,
      p_task_assignment_status,
      ddp_debrief_line_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end csf_debrief_pub_w;

/
