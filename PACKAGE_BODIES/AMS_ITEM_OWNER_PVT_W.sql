--------------------------------------------------------
--  DDL for Package Body AMS_ITEM_OWNER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ITEM_OWNER_PVT_W" as
  /* $Header: amswinvb.pls 120.3 2006/05/04 03:17 inanaiah ship $ */
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

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p3(t out nocopy ams_item_owner_pvt.item_owner_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).item_owner_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).item_number := a4(indx);
          t(ddindx).owner_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).status_code := a6(indx);
          t(ddindx).effective_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).is_master_item := a8(indx);
          t(ddindx).item_setup_type := a9(indx);
          t(ddindx).custom_setup_id := rosetta_g_miss_num_map(a10(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_item_owner_pvt.item_owner_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
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
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).item_owner_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a4(indx) := t(ddindx).item_number;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).owner_id);
          a6(indx) := t(ddindx).status_code;
          a7(indx) := t(ddindx).effective_date;
          a8(indx) := t(ddindx).is_master_item;
          a9(indx) := t(ddindx).item_setup_type;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).custom_setup_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p8(t out nocopy ams_item_owner_pvt.error_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).transaction_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).unique_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).message_name := a2(indx);
          t(ddindx).message_text := a3(indx);
          t(ddindx).table_name := a4(indx);
          t(ddindx).column_name := a5(indx);
          t(ddindx).organization_id := rosetta_g_miss_num_map(a6(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t ams_item_owner_pvt.error_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).transaction_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).unique_id);
          a2(indx) := t(ddindx).message_name;
          a3(indx) := t(ddindx).message_text;
          a4(indx) := t(ddindx).table_name;
          a5(indx) := t(ddindx).column_name;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure create_item_owner(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_item_owner_id out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  DATE
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  VARCHAR2
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  NUMBER
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  NUMBER
    , p10_a17 out nocopy  VARCHAR2
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  VARCHAR2
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  VARCHAR2
    , p10_a24 out nocopy  VARCHAR2
    , p10_a25 out nocopy  VARCHAR2
    , p10_a26 out nocopy  VARCHAR2
    , p10_a27 out nocopy  VARCHAR2
    , p10_a28 out nocopy  VARCHAR2
    , p10_a29 out nocopy  VARCHAR2
    , p10_a30 out nocopy  VARCHAR2
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  VARCHAR2
    , p10_a33 out nocopy  NUMBER
    , p10_a34 out nocopy  NUMBER
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  VARCHAR2
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  VARCHAR2
    , p10_a39 out nocopy  VARCHAR2
    , p10_a40 out nocopy  VARCHAR2
    , p10_a41 out nocopy  NUMBER
    , p10_a42 out nocopy  VARCHAR2
    , p10_a43 out nocopy  VARCHAR2
    , p10_a44 out nocopy  VARCHAR2
    , p10_a45 out nocopy  VARCHAR2
    , p10_a46 out nocopy  VARCHAR2
    , p10_a47 out nocopy  VARCHAR2
    , p10_a48 out nocopy  VARCHAR2
    , p10_a49 out nocopy  VARCHAR2
    , p10_a50 out nocopy  VARCHAR2
    , p10_a51 out nocopy  VARCHAR2
    , p10_a52 out nocopy  VARCHAR2
    , p10_a53 out nocopy  VARCHAR2
    , p10_a54 out nocopy  VARCHAR2
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  VARCHAR2
    , p10_a58 out nocopy  VARCHAR2
    , p10_a59 out nocopy  VARCHAR2
    , p10_a60 out nocopy  VARCHAR2
    , p10_a61 out nocopy  VARCHAR2
    , p10_a62 out nocopy  VARCHAR2
    , p10_a63 out nocopy  VARCHAR2
    , p10_a64 out nocopy  VARCHAR2
    , p10_a65 out nocopy  VARCHAR2
    , p10_a66 out nocopy  VARCHAR2
    , x_item_return_status out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
    , p9_a3  VARCHAR2 := fnd_api.g_miss_char
    , p9_a4  VARCHAR2 := fnd_api.g_miss_char
    , p9_a5  VARCHAR2 := fnd_api.g_miss_char
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a8  DATE := fnd_api.g_miss_date
    , p9_a9  DATE := fnd_api.g_miss_date
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  VARCHAR2 := fnd_api.g_miss_char
    , p9_a13  VARCHAR2 := fnd_api.g_miss_char
    , p9_a14  NUMBER := 0-1962.0724
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  NUMBER := 0-1962.0724
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  VARCHAR2 := fnd_api.g_miss_char
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  VARCHAR2 := fnd_api.g_miss_char
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  NUMBER := 0-1962.0724
    , p9_a34  NUMBER := 0-1962.0724
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  NUMBER := 0-1962.0724
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  VARCHAR2 := fnd_api.g_miss_char
    , p9_a44  VARCHAR2 := fnd_api.g_miss_char
    , p9_a45  VARCHAR2 := fnd_api.g_miss_char
    , p9_a46  VARCHAR2 := fnd_api.g_miss_char
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  VARCHAR2 := fnd_api.g_miss_char
    , p9_a51  VARCHAR2 := fnd_api.g_miss_char
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  VARCHAR2 := fnd_api.g_miss_char
    , p9_a55  VARCHAR2 := fnd_api.g_miss_char
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  VARCHAR2 := fnd_api.g_miss_char
    , p9_a58  VARCHAR2 := fnd_api.g_miss_char
    , p9_a59  VARCHAR2 := fnd_api.g_miss_char
    , p9_a60  VARCHAR2 := fnd_api.g_miss_char
    , p9_a61  VARCHAR2 := fnd_api.g_miss_char
    , p9_a62  VARCHAR2 := fnd_api.g_miss_char
    , p9_a63  VARCHAR2 := fnd_api.g_miss_char
    , p9_a64  VARCHAR2 := fnd_api.g_miss_char
    , p9_a65  VARCHAR2 := fnd_api.g_miss_char
    , p9_a66  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_item_owner_rec ams_item_owner_pvt.item_owner_rec_type;
    ddp_item_rec_in ams_item_owner_pvt.item_rec_type;
    ddp_item_rec_out ams_item_owner_pvt.item_rec_type;
    ddx_error_tbl ams_item_owner_pvt.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_item_owner_rec.item_owner_id := rosetta_g_miss_num_map(p7_a0);
    ddp_item_owner_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_item_owner_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a2);
    ddp_item_owner_rec.organization_id := rosetta_g_miss_num_map(p7_a3);
    ddp_item_owner_rec.item_number := p7_a4;
    ddp_item_owner_rec.owner_id := rosetta_g_miss_num_map(p7_a5);
    ddp_item_owner_rec.status_code := p7_a6;
    ddp_item_owner_rec.effective_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_item_owner_rec.is_master_item := p7_a8;
    ddp_item_owner_rec.item_setup_type := p7_a9;
    ddp_item_owner_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a10);


    ddp_item_rec_in.inventory_item_id := rosetta_g_miss_num_map(p9_a0);
    ddp_item_rec_in.organization_id := rosetta_g_miss_num_map(p9_a1);
    ddp_item_rec_in.item_number := p9_a2;
    ddp_item_rec_in.description := p9_a3;
    ddp_item_rec_in.long_description := p9_a4;
    ddp_item_rec_in.item_type := p9_a5;
    ddp_item_rec_in.primary_uom_code := p9_a6;
    ddp_item_rec_in.primary_unit_of_measure := p9_a7;
    ddp_item_rec_in.start_date_active := rosetta_g_miss_date_in_map(p9_a8);
    ddp_item_rec_in.end_date_active := rosetta_g_miss_date_in_map(p9_a9);
    ddp_item_rec_in.inventory_item_status_code := p9_a10;
    ddp_item_rec_in.inventory_item_flag := p9_a11;
    ddp_item_rec_in.stock_enabled_flag := p9_a12;
    ddp_item_rec_in.mtl_transactions_enabled_flag := p9_a13;
    ddp_item_rec_in.revision_qty_control_code := rosetta_g_miss_num_map(p9_a14);
    ddp_item_rec_in.bom_enabled_flag := p9_a15;
    ddp_item_rec_in.bom_item_type := rosetta_g_miss_num_map(p9_a16);
    ddp_item_rec_in.costing_enabled_flag := p9_a17;
    ddp_item_rec_in.electronic_flag := p9_a18;
    ddp_item_rec_in.downloadable_flag := p9_a19;
    ddp_item_rec_in.customer_order_flag := p9_a20;
    ddp_item_rec_in.customer_order_enabled_flag := p9_a21;
    ddp_item_rec_in.internal_order_flag := p9_a22;
    ddp_item_rec_in.internal_order_enabled_flag := p9_a23;
    ddp_item_rec_in.shippable_item_flag := p9_a24;
    ddp_item_rec_in.returnable_flag := p9_a25;
    ddp_item_rec_in.comms_activation_reqd_flag := p9_a26;
    ddp_item_rec_in.replenish_to_order_flag := p9_a27;
    ddp_item_rec_in.invoiceable_item_flag := p9_a28;
    ddp_item_rec_in.invoice_enabled_flag := p9_a29;
    ddp_item_rec_in.service_item_flag := p9_a30;
    ddp_item_rec_in.serviceable_product_flag := p9_a31;
    ddp_item_rec_in.vendor_warranty_flag := p9_a32;
    ddp_item_rec_in.coverage_schedule_id := rosetta_g_miss_num_map(p9_a33);
    ddp_item_rec_in.service_duration := rosetta_g_miss_num_map(p9_a34);
    ddp_item_rec_in.service_duration_period_code := p9_a35;
    ddp_item_rec_in.defect_tracking_on_flag := p9_a36;
    ddp_item_rec_in.orderable_on_web_flag := p9_a37;
    ddp_item_rec_in.back_orderable_flag := p9_a38;
    ddp_item_rec_in.collateral_flag := p9_a39;
    ddp_item_rec_in.weight_uom_code := p9_a40;
    ddp_item_rec_in.unit_weight := rosetta_g_miss_num_map(p9_a41);
    ddp_item_rec_in.event_flag := p9_a42;
    ddp_item_rec_in.comms_nl_trackable_flag := p9_a43;
    ddp_item_rec_in.subscription_depend_flag := p9_a44;
    ddp_item_rec_in.contract_item_type_code := p9_a45;
    ddp_item_rec_in.web_status := p9_a46;
    ddp_item_rec_in.indivisible_flag := p9_a47;
    ddp_item_rec_in.material_billable_flag := p9_a48;
    ddp_item_rec_in.pick_components_flag := p9_a49;
    ddp_item_rec_in.so_transactions_flag := p9_a50;
    ddp_item_rec_in.attribute_category := p9_a51;
    ddp_item_rec_in.attribute1 := p9_a52;
    ddp_item_rec_in.attribute2 := p9_a53;
    ddp_item_rec_in.attribute3 := p9_a54;
    ddp_item_rec_in.attribute4 := p9_a55;
    ddp_item_rec_in.attribute5 := p9_a56;
    ddp_item_rec_in.attribute6 := p9_a57;
    ddp_item_rec_in.attribute7 := p9_a58;
    ddp_item_rec_in.attribute8 := p9_a59;
    ddp_item_rec_in.attribute9 := p9_a60;
    ddp_item_rec_in.attribute10 := p9_a61;
    ddp_item_rec_in.attribute11 := p9_a62;
    ddp_item_rec_in.attribute12 := p9_a63;
    ddp_item_rec_in.attribute13 := p9_a64;
    ddp_item_rec_in.attribute14 := p9_a65;
    ddp_item_rec_in.attribute15 := p9_a66;




    -- here's the delegated call to the old PL/SQL routine
    ams_item_owner_pvt.create_item_owner(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_item_owner_rec,
      x_item_owner_id,
      ddp_item_rec_in,
      ddp_item_rec_out,
      x_item_return_status,
      ddx_error_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddp_item_rec_out.inventory_item_id);
    p10_a1 := rosetta_g_miss_num_map(ddp_item_rec_out.organization_id);
    p10_a2 := ddp_item_rec_out.item_number;
    p10_a3 := ddp_item_rec_out.description;
    p10_a4 := ddp_item_rec_out.long_description;
    p10_a5 := ddp_item_rec_out.item_type;
    p10_a6 := ddp_item_rec_out.primary_uom_code;
    p10_a7 := ddp_item_rec_out.primary_unit_of_measure;
    p10_a8 := ddp_item_rec_out.start_date_active;
    p10_a9 := ddp_item_rec_out.end_date_active;
    p10_a10 := ddp_item_rec_out.inventory_item_status_code;
    p10_a11 := ddp_item_rec_out.inventory_item_flag;
    p10_a12 := ddp_item_rec_out.stock_enabled_flag;
    p10_a13 := ddp_item_rec_out.mtl_transactions_enabled_flag;
    p10_a14 := rosetta_g_miss_num_map(ddp_item_rec_out.revision_qty_control_code);
    p10_a15 := ddp_item_rec_out.bom_enabled_flag;
    p10_a16 := rosetta_g_miss_num_map(ddp_item_rec_out.bom_item_type);
    p10_a17 := ddp_item_rec_out.costing_enabled_flag;
    p10_a18 := ddp_item_rec_out.electronic_flag;
    p10_a19 := ddp_item_rec_out.downloadable_flag;
    p10_a20 := ddp_item_rec_out.customer_order_flag;
    p10_a21 := ddp_item_rec_out.customer_order_enabled_flag;
    p10_a22 := ddp_item_rec_out.internal_order_flag;
    p10_a23 := ddp_item_rec_out.internal_order_enabled_flag;
    p10_a24 := ddp_item_rec_out.shippable_item_flag;
    p10_a25 := ddp_item_rec_out.returnable_flag;
    p10_a26 := ddp_item_rec_out.comms_activation_reqd_flag;
    p10_a27 := ddp_item_rec_out.replenish_to_order_flag;
    p10_a28 := ddp_item_rec_out.invoiceable_item_flag;
    p10_a29 := ddp_item_rec_out.invoice_enabled_flag;
    p10_a30 := ddp_item_rec_out.service_item_flag;
    p10_a31 := ddp_item_rec_out.serviceable_product_flag;
    p10_a32 := ddp_item_rec_out.vendor_warranty_flag;
    p10_a33 := rosetta_g_miss_num_map(ddp_item_rec_out.coverage_schedule_id);
    p10_a34 := rosetta_g_miss_num_map(ddp_item_rec_out.service_duration);
    p10_a35 := ddp_item_rec_out.service_duration_period_code;
    p10_a36 := ddp_item_rec_out.defect_tracking_on_flag;
    p10_a37 := ddp_item_rec_out.orderable_on_web_flag;
    p10_a38 := ddp_item_rec_out.back_orderable_flag;
    p10_a39 := ddp_item_rec_out.collateral_flag;
    p10_a40 := ddp_item_rec_out.weight_uom_code;
    p10_a41 := rosetta_g_miss_num_map(ddp_item_rec_out.unit_weight);
    p10_a42 := ddp_item_rec_out.event_flag;
    p10_a43 := ddp_item_rec_out.comms_nl_trackable_flag;
    p10_a44 := ddp_item_rec_out.subscription_depend_flag;
    p10_a45 := ddp_item_rec_out.contract_item_type_code;
    p10_a46 := ddp_item_rec_out.web_status;
    p10_a47 := ddp_item_rec_out.indivisible_flag;
    p10_a48 := ddp_item_rec_out.material_billable_flag;
    p10_a49 := ddp_item_rec_out.pick_components_flag;
    p10_a50 := ddp_item_rec_out.so_transactions_flag;
    p10_a51 := ddp_item_rec_out.attribute_category;
    p10_a52 := ddp_item_rec_out.attribute1;
    p10_a53 := ddp_item_rec_out.attribute2;
    p10_a54 := ddp_item_rec_out.attribute3;
    p10_a55 := ddp_item_rec_out.attribute4;
    p10_a56 := ddp_item_rec_out.attribute5;
    p10_a57 := ddp_item_rec_out.attribute6;
    p10_a58 := ddp_item_rec_out.attribute7;
    p10_a59 := ddp_item_rec_out.attribute8;
    p10_a60 := ddp_item_rec_out.attribute9;
    p10_a61 := ddp_item_rec_out.attribute10;
    p10_a62 := ddp_item_rec_out.attribute11;
    p10_a63 := ddp_item_rec_out.attribute12;
    p10_a64 := ddp_item_rec_out.attribute13;
    p10_a65 := ddp_item_rec_out.attribute14;
    p10_a66 := ddp_item_rec_out.attribute15;


    ams_item_owner_pvt_w.rosetta_table_copy_out_p8(ddx_error_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      );
  end;

  procedure update_item_owner(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  VARCHAR2
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  DATE
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  VARCHAR2
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  NUMBER
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  NUMBER
    , p10_a17 out nocopy  VARCHAR2
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  VARCHAR2
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  VARCHAR2
    , p10_a24 out nocopy  VARCHAR2
    , p10_a25 out nocopy  VARCHAR2
    , p10_a26 out nocopy  VARCHAR2
    , p10_a27 out nocopy  VARCHAR2
    , p10_a28 out nocopy  VARCHAR2
    , p10_a29 out nocopy  VARCHAR2
    , p10_a30 out nocopy  VARCHAR2
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  VARCHAR2
    , p10_a33 out nocopy  NUMBER
    , p10_a34 out nocopy  NUMBER
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  VARCHAR2
    , p10_a37 out nocopy  VARCHAR2
    , p10_a38 out nocopy  VARCHAR2
    , p10_a39 out nocopy  VARCHAR2
    , p10_a40 out nocopy  VARCHAR2
    , p10_a41 out nocopy  NUMBER
    , p10_a42 out nocopy  VARCHAR2
    , p10_a43 out nocopy  VARCHAR2
    , p10_a44 out nocopy  VARCHAR2
    , p10_a45 out nocopy  VARCHAR2
    , p10_a46 out nocopy  VARCHAR2
    , p10_a47 out nocopy  VARCHAR2
    , p10_a48 out nocopy  VARCHAR2
    , p10_a49 out nocopy  VARCHAR2
    , p10_a50 out nocopy  VARCHAR2
    , p10_a51 out nocopy  VARCHAR2
    , p10_a52 out nocopy  VARCHAR2
    , p10_a53 out nocopy  VARCHAR2
    , p10_a54 out nocopy  VARCHAR2
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  VARCHAR2
    , p10_a58 out nocopy  VARCHAR2
    , p10_a59 out nocopy  VARCHAR2
    , p10_a60 out nocopy  VARCHAR2
    , p10_a61 out nocopy  VARCHAR2
    , p10_a62 out nocopy  VARCHAR2
    , p10_a63 out nocopy  VARCHAR2
    , p10_a64 out nocopy  VARCHAR2
    , p10_a65 out nocopy  VARCHAR2
    , p10_a66 out nocopy  VARCHAR2
    , x_item_return_status out nocopy  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
    , p9_a3  VARCHAR2 := fnd_api.g_miss_char
    , p9_a4  VARCHAR2 := fnd_api.g_miss_char
    , p9_a5  VARCHAR2 := fnd_api.g_miss_char
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a8  DATE := fnd_api.g_miss_date
    , p9_a9  DATE := fnd_api.g_miss_date
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  VARCHAR2 := fnd_api.g_miss_char
    , p9_a13  VARCHAR2 := fnd_api.g_miss_char
    , p9_a14  NUMBER := 0-1962.0724
    , p9_a15  VARCHAR2 := fnd_api.g_miss_char
    , p9_a16  NUMBER := 0-1962.0724
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  VARCHAR2 := fnd_api.g_miss_char
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  VARCHAR2 := fnd_api.g_miss_char
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  NUMBER := 0-1962.0724
    , p9_a34  NUMBER := 0-1962.0724
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  NUMBER := 0-1962.0724
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  VARCHAR2 := fnd_api.g_miss_char
    , p9_a44  VARCHAR2 := fnd_api.g_miss_char
    , p9_a45  VARCHAR2 := fnd_api.g_miss_char
    , p9_a46  VARCHAR2 := fnd_api.g_miss_char
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  VARCHAR2 := fnd_api.g_miss_char
    , p9_a51  VARCHAR2 := fnd_api.g_miss_char
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  VARCHAR2 := fnd_api.g_miss_char
    , p9_a55  VARCHAR2 := fnd_api.g_miss_char
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  VARCHAR2 := fnd_api.g_miss_char
    , p9_a58  VARCHAR2 := fnd_api.g_miss_char
    , p9_a59  VARCHAR2 := fnd_api.g_miss_char
    , p9_a60  VARCHAR2 := fnd_api.g_miss_char
    , p9_a61  VARCHAR2 := fnd_api.g_miss_char
    , p9_a62  VARCHAR2 := fnd_api.g_miss_char
    , p9_a63  VARCHAR2 := fnd_api.g_miss_char
    , p9_a64  VARCHAR2 := fnd_api.g_miss_char
    , p9_a65  VARCHAR2 := fnd_api.g_miss_char
    , p9_a66  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_item_owner_rec ams_item_owner_pvt.item_owner_rec_type;
    ddp_item_rec_in ams_item_owner_pvt.item_rec_type;
    ddp_item_rec_out ams_item_owner_pvt.item_rec_type;
    ddx_error_tbl ams_item_owner_pvt.error_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_item_owner_rec.item_owner_id := rosetta_g_miss_num_map(p7_a0);
    ddp_item_owner_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_item_owner_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a2);
    ddp_item_owner_rec.organization_id := rosetta_g_miss_num_map(p7_a3);
    ddp_item_owner_rec.item_number := p7_a4;
    ddp_item_owner_rec.owner_id := rosetta_g_miss_num_map(p7_a5);
    ddp_item_owner_rec.status_code := p7_a6;
    ddp_item_owner_rec.effective_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_item_owner_rec.is_master_item := p7_a8;
    ddp_item_owner_rec.item_setup_type := p7_a9;
    ddp_item_owner_rec.custom_setup_id := rosetta_g_miss_num_map(p7_a10);


    ddp_item_rec_in.inventory_item_id := rosetta_g_miss_num_map(p9_a0);
    ddp_item_rec_in.organization_id := rosetta_g_miss_num_map(p9_a1);
    ddp_item_rec_in.item_number := p9_a2;
    ddp_item_rec_in.description := p9_a3;
    ddp_item_rec_in.long_description := p9_a4;
    ddp_item_rec_in.item_type := p9_a5;
    ddp_item_rec_in.primary_uom_code := p9_a6;
    ddp_item_rec_in.primary_unit_of_measure := p9_a7;
    ddp_item_rec_in.start_date_active := rosetta_g_miss_date_in_map(p9_a8);
    ddp_item_rec_in.end_date_active := rosetta_g_miss_date_in_map(p9_a9);
    ddp_item_rec_in.inventory_item_status_code := p9_a10;
    ddp_item_rec_in.inventory_item_flag := p9_a11;
    ddp_item_rec_in.stock_enabled_flag := p9_a12;
    ddp_item_rec_in.mtl_transactions_enabled_flag := p9_a13;
    ddp_item_rec_in.revision_qty_control_code := rosetta_g_miss_num_map(p9_a14);
    ddp_item_rec_in.bom_enabled_flag := p9_a15;
    ddp_item_rec_in.bom_item_type := rosetta_g_miss_num_map(p9_a16);
    ddp_item_rec_in.costing_enabled_flag := p9_a17;
    ddp_item_rec_in.electronic_flag := p9_a18;
    ddp_item_rec_in.downloadable_flag := p9_a19;
    ddp_item_rec_in.customer_order_flag := p9_a20;
    ddp_item_rec_in.customer_order_enabled_flag := p9_a21;
    ddp_item_rec_in.internal_order_flag := p9_a22;
    ddp_item_rec_in.internal_order_enabled_flag := p9_a23;
    ddp_item_rec_in.shippable_item_flag := p9_a24;
    ddp_item_rec_in.returnable_flag := p9_a25;
    ddp_item_rec_in.comms_activation_reqd_flag := p9_a26;
    ddp_item_rec_in.replenish_to_order_flag := p9_a27;
    ddp_item_rec_in.invoiceable_item_flag := p9_a28;
    ddp_item_rec_in.invoice_enabled_flag := p9_a29;
    ddp_item_rec_in.service_item_flag := p9_a30;
    ddp_item_rec_in.serviceable_product_flag := p9_a31;
    ddp_item_rec_in.vendor_warranty_flag := p9_a32;
    ddp_item_rec_in.coverage_schedule_id := rosetta_g_miss_num_map(p9_a33);
    ddp_item_rec_in.service_duration := rosetta_g_miss_num_map(p9_a34);
    ddp_item_rec_in.service_duration_period_code := p9_a35;
    ddp_item_rec_in.defect_tracking_on_flag := p9_a36;
    ddp_item_rec_in.orderable_on_web_flag := p9_a37;
    ddp_item_rec_in.back_orderable_flag := p9_a38;
    ddp_item_rec_in.collateral_flag := p9_a39;
    ddp_item_rec_in.weight_uom_code := p9_a40;
    ddp_item_rec_in.unit_weight := rosetta_g_miss_num_map(p9_a41);
    ddp_item_rec_in.event_flag := p9_a42;
    ddp_item_rec_in.comms_nl_trackable_flag := p9_a43;
    ddp_item_rec_in.subscription_depend_flag := p9_a44;
    ddp_item_rec_in.contract_item_type_code := p9_a45;
    ddp_item_rec_in.web_status := p9_a46;
    ddp_item_rec_in.indivisible_flag := p9_a47;
    ddp_item_rec_in.material_billable_flag := p9_a48;
    ddp_item_rec_in.pick_components_flag := p9_a49;
    ddp_item_rec_in.so_transactions_flag := p9_a50;
    ddp_item_rec_in.attribute_category := p9_a51;
    ddp_item_rec_in.attribute1 := p9_a52;
    ddp_item_rec_in.attribute2 := p9_a53;
    ddp_item_rec_in.attribute3 := p9_a54;
    ddp_item_rec_in.attribute4 := p9_a55;
    ddp_item_rec_in.attribute5 := p9_a56;
    ddp_item_rec_in.attribute6 := p9_a57;
    ddp_item_rec_in.attribute7 := p9_a58;
    ddp_item_rec_in.attribute8 := p9_a59;
    ddp_item_rec_in.attribute9 := p9_a60;
    ddp_item_rec_in.attribute10 := p9_a61;
    ddp_item_rec_in.attribute11 := p9_a62;
    ddp_item_rec_in.attribute12 := p9_a63;
    ddp_item_rec_in.attribute13 := p9_a64;
    ddp_item_rec_in.attribute14 := p9_a65;
    ddp_item_rec_in.attribute15 := p9_a66;




    -- here's the delegated call to the old PL/SQL routine
    ams_item_owner_pvt.update_item_owner(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_item_owner_rec,
      x_object_version_number,
      ddp_item_rec_in,
      ddp_item_rec_out,
      x_item_return_status,
      ddx_error_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddp_item_rec_out.inventory_item_id);
    p10_a1 := rosetta_g_miss_num_map(ddp_item_rec_out.organization_id);
    p10_a2 := ddp_item_rec_out.item_number;
    p10_a3 := ddp_item_rec_out.description;
    p10_a4 := ddp_item_rec_out.long_description;
    p10_a5 := ddp_item_rec_out.item_type;
    p10_a6 := ddp_item_rec_out.primary_uom_code;
    p10_a7 := ddp_item_rec_out.primary_unit_of_measure;
    p10_a8 := ddp_item_rec_out.start_date_active;
    p10_a9 := ddp_item_rec_out.end_date_active;
    p10_a10 := ddp_item_rec_out.inventory_item_status_code;
    p10_a11 := ddp_item_rec_out.inventory_item_flag;
    p10_a12 := ddp_item_rec_out.stock_enabled_flag;
    p10_a13 := ddp_item_rec_out.mtl_transactions_enabled_flag;
    p10_a14 := rosetta_g_miss_num_map(ddp_item_rec_out.revision_qty_control_code);
    p10_a15 := ddp_item_rec_out.bom_enabled_flag;
    p10_a16 := rosetta_g_miss_num_map(ddp_item_rec_out.bom_item_type);
    p10_a17 := ddp_item_rec_out.costing_enabled_flag;
    p10_a18 := ddp_item_rec_out.electronic_flag;
    p10_a19 := ddp_item_rec_out.downloadable_flag;
    p10_a20 := ddp_item_rec_out.customer_order_flag;
    p10_a21 := ddp_item_rec_out.customer_order_enabled_flag;
    p10_a22 := ddp_item_rec_out.internal_order_flag;
    p10_a23 := ddp_item_rec_out.internal_order_enabled_flag;
    p10_a24 := ddp_item_rec_out.shippable_item_flag;
    p10_a25 := ddp_item_rec_out.returnable_flag;
    p10_a26 := ddp_item_rec_out.comms_activation_reqd_flag;
    p10_a27 := ddp_item_rec_out.replenish_to_order_flag;
    p10_a28 := ddp_item_rec_out.invoiceable_item_flag;
    p10_a29 := ddp_item_rec_out.invoice_enabled_flag;
    p10_a30 := ddp_item_rec_out.service_item_flag;
    p10_a31 := ddp_item_rec_out.serviceable_product_flag;
    p10_a32 := ddp_item_rec_out.vendor_warranty_flag;
    p10_a33 := rosetta_g_miss_num_map(ddp_item_rec_out.coverage_schedule_id);
    p10_a34 := rosetta_g_miss_num_map(ddp_item_rec_out.service_duration);
    p10_a35 := ddp_item_rec_out.service_duration_period_code;
    p10_a36 := ddp_item_rec_out.defect_tracking_on_flag;
    p10_a37 := ddp_item_rec_out.orderable_on_web_flag;
    p10_a38 := ddp_item_rec_out.back_orderable_flag;
    p10_a39 := ddp_item_rec_out.collateral_flag;
    p10_a40 := ddp_item_rec_out.weight_uom_code;
    p10_a41 := rosetta_g_miss_num_map(ddp_item_rec_out.unit_weight);
    p10_a42 := ddp_item_rec_out.event_flag;
    p10_a43 := ddp_item_rec_out.comms_nl_trackable_flag;
    p10_a44 := ddp_item_rec_out.subscription_depend_flag;
    p10_a45 := ddp_item_rec_out.contract_item_type_code;
    p10_a46 := ddp_item_rec_out.web_status;
    p10_a47 := ddp_item_rec_out.indivisible_flag;
    p10_a48 := ddp_item_rec_out.material_billable_flag;
    p10_a49 := ddp_item_rec_out.pick_components_flag;
    p10_a50 := ddp_item_rec_out.so_transactions_flag;
    p10_a51 := ddp_item_rec_out.attribute_category;
    p10_a52 := ddp_item_rec_out.attribute1;
    p10_a53 := ddp_item_rec_out.attribute2;
    p10_a54 := ddp_item_rec_out.attribute3;
    p10_a55 := ddp_item_rec_out.attribute4;
    p10_a56 := ddp_item_rec_out.attribute5;
    p10_a57 := ddp_item_rec_out.attribute6;
    p10_a58 := ddp_item_rec_out.attribute7;
    p10_a59 := ddp_item_rec_out.attribute8;
    p10_a60 := ddp_item_rec_out.attribute9;
    p10_a61 := ddp_item_rec_out.attribute10;
    p10_a62 := ddp_item_rec_out.attribute11;
    p10_a63 := ddp_item_rec_out.attribute12;
    p10_a64 := ddp_item_rec_out.attribute13;
    p10_a65 := ddp_item_rec_out.attribute14;
    p10_a66 := ddp_item_rec_out.attribute15;


    ams_item_owner_pvt_w.rosetta_table_copy_out_p8(ddx_error_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      );
  end;

  procedure validate_item_owner(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  DATE := fnd_api.g_miss_date
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  DATE := fnd_api.g_miss_date
    , p4_a9  DATE := fnd_api.g_miss_date
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  NUMBER := 0-1962.0724
    , p4_a42  VARCHAR2 := fnd_api.g_miss_char
    , p4_a43  VARCHAR2 := fnd_api.g_miss_char
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  VARCHAR2 := fnd_api.g_miss_char
    , p4_a56  VARCHAR2 := fnd_api.g_miss_char
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  VARCHAR2 := fnd_api.g_miss_char
    , p4_a64  VARCHAR2 := fnd_api.g_miss_char
    , p4_a65  VARCHAR2 := fnd_api.g_miss_char
    , p4_a66  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_item_owner_rec ams_item_owner_pvt.item_owner_rec_type;
    ddp_item_rec_in ams_item_owner_pvt.item_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_item_owner_rec.item_owner_id := rosetta_g_miss_num_map(p3_a0);
    ddp_item_owner_rec.object_version_number := rosetta_g_miss_num_map(p3_a1);
    ddp_item_owner_rec.inventory_item_id := rosetta_g_miss_num_map(p3_a2);
    ddp_item_owner_rec.organization_id := rosetta_g_miss_num_map(p3_a3);
    ddp_item_owner_rec.item_number := p3_a4;
    ddp_item_owner_rec.owner_id := rosetta_g_miss_num_map(p3_a5);
    ddp_item_owner_rec.status_code := p3_a6;
    ddp_item_owner_rec.effective_date := rosetta_g_miss_date_in_map(p3_a7);
    ddp_item_owner_rec.is_master_item := p3_a8;
    ddp_item_owner_rec.item_setup_type := p3_a9;
    ddp_item_owner_rec.custom_setup_id := rosetta_g_miss_num_map(p3_a10);

    ddp_item_rec_in.inventory_item_id := rosetta_g_miss_num_map(p4_a0);
    ddp_item_rec_in.organization_id := rosetta_g_miss_num_map(p4_a1);
    ddp_item_rec_in.item_number := p4_a2;
    ddp_item_rec_in.description := p4_a3;
    ddp_item_rec_in.long_description := p4_a4;
    ddp_item_rec_in.item_type := p4_a5;
    ddp_item_rec_in.primary_uom_code := p4_a6;
    ddp_item_rec_in.primary_unit_of_measure := p4_a7;
    ddp_item_rec_in.start_date_active := rosetta_g_miss_date_in_map(p4_a8);
    ddp_item_rec_in.end_date_active := rosetta_g_miss_date_in_map(p4_a9);
    ddp_item_rec_in.inventory_item_status_code := p4_a10;
    ddp_item_rec_in.inventory_item_flag := p4_a11;
    ddp_item_rec_in.stock_enabled_flag := p4_a12;
    ddp_item_rec_in.mtl_transactions_enabled_flag := p4_a13;
    ddp_item_rec_in.revision_qty_control_code := rosetta_g_miss_num_map(p4_a14);
    ddp_item_rec_in.bom_enabled_flag := p4_a15;
    ddp_item_rec_in.bom_item_type := rosetta_g_miss_num_map(p4_a16);
    ddp_item_rec_in.costing_enabled_flag := p4_a17;
    ddp_item_rec_in.electronic_flag := p4_a18;
    ddp_item_rec_in.downloadable_flag := p4_a19;
    ddp_item_rec_in.customer_order_flag := p4_a20;
    ddp_item_rec_in.customer_order_enabled_flag := p4_a21;
    ddp_item_rec_in.internal_order_flag := p4_a22;
    ddp_item_rec_in.internal_order_enabled_flag := p4_a23;
    ddp_item_rec_in.shippable_item_flag := p4_a24;
    ddp_item_rec_in.returnable_flag := p4_a25;
    ddp_item_rec_in.comms_activation_reqd_flag := p4_a26;
    ddp_item_rec_in.replenish_to_order_flag := p4_a27;
    ddp_item_rec_in.invoiceable_item_flag := p4_a28;
    ddp_item_rec_in.invoice_enabled_flag := p4_a29;
    ddp_item_rec_in.service_item_flag := p4_a30;
    ddp_item_rec_in.serviceable_product_flag := p4_a31;
    ddp_item_rec_in.vendor_warranty_flag := p4_a32;
    ddp_item_rec_in.coverage_schedule_id := rosetta_g_miss_num_map(p4_a33);
    ddp_item_rec_in.service_duration := rosetta_g_miss_num_map(p4_a34);
    ddp_item_rec_in.service_duration_period_code := p4_a35;
    ddp_item_rec_in.defect_tracking_on_flag := p4_a36;
    ddp_item_rec_in.orderable_on_web_flag := p4_a37;
    ddp_item_rec_in.back_orderable_flag := p4_a38;
    ddp_item_rec_in.collateral_flag := p4_a39;
    ddp_item_rec_in.weight_uom_code := p4_a40;
    ddp_item_rec_in.unit_weight := rosetta_g_miss_num_map(p4_a41);
    ddp_item_rec_in.event_flag := p4_a42;
    ddp_item_rec_in.comms_nl_trackable_flag := p4_a43;
    ddp_item_rec_in.subscription_depend_flag := p4_a44;
    ddp_item_rec_in.contract_item_type_code := p4_a45;
    ddp_item_rec_in.web_status := p4_a46;
    ddp_item_rec_in.indivisible_flag := p4_a47;
    ddp_item_rec_in.material_billable_flag := p4_a48;
    ddp_item_rec_in.pick_components_flag := p4_a49;
    ddp_item_rec_in.so_transactions_flag := p4_a50;
    ddp_item_rec_in.attribute_category := p4_a51;
    ddp_item_rec_in.attribute1 := p4_a52;
    ddp_item_rec_in.attribute2 := p4_a53;
    ddp_item_rec_in.attribute3 := p4_a54;
    ddp_item_rec_in.attribute4 := p4_a55;
    ddp_item_rec_in.attribute5 := p4_a56;
    ddp_item_rec_in.attribute6 := p4_a57;
    ddp_item_rec_in.attribute7 := p4_a58;
    ddp_item_rec_in.attribute8 := p4_a59;
    ddp_item_rec_in.attribute9 := p4_a60;
    ddp_item_rec_in.attribute10 := p4_a61;
    ddp_item_rec_in.attribute11 := p4_a62;
    ddp_item_rec_in.attribute12 := p4_a63;
    ddp_item_rec_in.attribute13 := p4_a64;
    ddp_item_rec_in.attribute14 := p4_a65;
    ddp_item_rec_in.attribute15 := p4_a66;




    -- here's the delegated call to the old PL/SQL routine
    ams_item_owner_pvt.validate_item_owner(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_item_owner_rec,
      ddp_item_rec_in,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ams_item_owner_pvt_w;

/
