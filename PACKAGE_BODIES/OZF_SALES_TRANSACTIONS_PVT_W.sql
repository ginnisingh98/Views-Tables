--------------------------------------------------------
--  DDL for Package Body OZF_SALES_TRANSACTIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SALES_TRANSACTIONS_PVT_W" as
  /* $Header: ozfwstnb.pls 115.2 2004/04/07 13:41:08 sangara noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ozf_sales_transactions_pvt.sales_trans_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).sales_transaction_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).last_update_date := a2(indx);
          t(ddindx).last_updated_by := a3(indx);
          t(ddindx).creation_date := a4(indx);
          t(ddindx).request_id := a5(indx);
          t(ddindx).created_by := a6(indx);
          t(ddindx).created_from := a7(indx);
          t(ddindx).last_update_login := a8(indx);
          t(ddindx).program_application_id := a9(indx);
          t(ddindx).program_update_date := a10(indx);
          t(ddindx).program_id := a11(indx);
          t(ddindx).transfer_type := a12(indx);
          t(ddindx).sold_from_cust_account_id := a13(indx);
          t(ddindx).sold_from_party_id := a14(indx);
          t(ddindx).sold_from_party_site_id := a15(indx);
          t(ddindx).sold_to_cust_account_id := a16(indx);
          t(ddindx).sold_to_party_id := a17(indx);
          t(ddindx).sold_to_party_site_id := a18(indx);
          t(ddindx).bill_to_site_use_id := a19(indx);
          t(ddindx).ship_to_site_use_id := a20(indx);
          t(ddindx).transaction_date := a21(indx);
          t(ddindx).quantity := a22(indx);
          t(ddindx).uom_code := a23(indx);
          t(ddindx).amount := a24(indx);
          t(ddindx).currency_code := a25(indx);
          t(ddindx).inventory_item_id := a26(indx);
          t(ddindx).primary_quantity := a27(indx);
          t(ddindx).primary_uom_code := a28(indx);
          t(ddindx).common_quantity := a29(indx);
          t(ddindx).common_uom_code := a30(indx);
          t(ddindx).common_currency_code := a31(indx);
          t(ddindx).common_amount := a32(indx);
          t(ddindx).header_id := a33(indx);
          t(ddindx).line_id := a34(indx);
          t(ddindx).reason_code := a35(indx);
          t(ddindx).source_code := a36(indx);
          t(ddindx).error_flag := a37(indx);
          t(ddindx).attribute_category := a38(indx);
          t(ddindx).attribute1 := a39(indx);
          t(ddindx).attribute2 := a40(indx);
          t(ddindx).attribute3 := a41(indx);
          t(ddindx).attribute4 := a42(indx);
          t(ddindx).attribute5 := a43(indx);
          t(ddindx).attribute6 := a44(indx);
          t(ddindx).attribute7 := a45(indx);
          t(ddindx).attribute8 := a46(indx);
          t(ddindx).attribute9 := a47(indx);
          t(ddindx).attribute10 := a48(indx);
          t(ddindx).attribute11 := a49(indx);
          t(ddindx).attribute12 := a50(indx);
          t(ddindx).attribute13 := a51(indx);
          t(ddindx).attribute14 := a52(indx);
          t(ddindx).attribute15 := a53(indx);
          t(ddindx).org_id := a54(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ozf_sales_transactions_pvt.sales_trans_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_VARCHAR2_TABLE_300
    , a45 out nocopy JTF_VARCHAR2_TABLE_300
    , a46 out nocopy JTF_VARCHAR2_TABLE_300
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_VARCHAR2_TABLE_300
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_300
    , a52 out nocopy JTF_VARCHAR2_TABLE_300
    , a53 out nocopy JTF_VARCHAR2_TABLE_300
    , a54 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_DATE_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_VARCHAR2_TABLE_300();
    a41 := JTF_VARCHAR2_TABLE_300();
    a42 := JTF_VARCHAR2_TABLE_300();
    a43 := JTF_VARCHAR2_TABLE_300();
    a44 := JTF_VARCHAR2_TABLE_300();
    a45 := JTF_VARCHAR2_TABLE_300();
    a46 := JTF_VARCHAR2_TABLE_300();
    a47 := JTF_VARCHAR2_TABLE_300();
    a48 := JTF_VARCHAR2_TABLE_300();
    a49 := JTF_VARCHAR2_TABLE_300();
    a50 := JTF_VARCHAR2_TABLE_300();
    a51 := JTF_VARCHAR2_TABLE_300();
    a52 := JTF_VARCHAR2_TABLE_300();
    a53 := JTF_VARCHAR2_TABLE_300();
    a54 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_DATE_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_VARCHAR2_TABLE_300();
      a41 := JTF_VARCHAR2_TABLE_300();
      a42 := JTF_VARCHAR2_TABLE_300();
      a43 := JTF_VARCHAR2_TABLE_300();
      a44 := JTF_VARCHAR2_TABLE_300();
      a45 := JTF_VARCHAR2_TABLE_300();
      a46 := JTF_VARCHAR2_TABLE_300();
      a47 := JTF_VARCHAR2_TABLE_300();
      a48 := JTF_VARCHAR2_TABLE_300();
      a49 := JTF_VARCHAR2_TABLE_300();
      a50 := JTF_VARCHAR2_TABLE_300();
      a51 := JTF_VARCHAR2_TABLE_300();
      a52 := JTF_VARCHAR2_TABLE_300();
      a53 := JTF_VARCHAR2_TABLE_300();
      a54 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).sales_transaction_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := t(ddindx).last_updated_by;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).request_id;
          a6(indx) := t(ddindx).created_by;
          a7(indx) := t(ddindx).created_from;
          a8(indx) := t(ddindx).last_update_login;
          a9(indx) := t(ddindx).program_application_id;
          a10(indx) := t(ddindx).program_update_date;
          a11(indx) := t(ddindx).program_id;
          a12(indx) := t(ddindx).transfer_type;
          a13(indx) := t(ddindx).sold_from_cust_account_id;
          a14(indx) := t(ddindx).sold_from_party_id;
          a15(indx) := t(ddindx).sold_from_party_site_id;
          a16(indx) := t(ddindx).sold_to_cust_account_id;
          a17(indx) := t(ddindx).sold_to_party_id;
          a18(indx) := t(ddindx).sold_to_party_site_id;
          a19(indx) := t(ddindx).bill_to_site_use_id;
          a20(indx) := t(ddindx).ship_to_site_use_id;
          a21(indx) := t(ddindx).transaction_date;
          a22(indx) := t(ddindx).quantity;
          a23(indx) := t(ddindx).uom_code;
          a24(indx) := t(ddindx).amount;
          a25(indx) := t(ddindx).currency_code;
          a26(indx) := t(ddindx).inventory_item_id;
          a27(indx) := t(ddindx).primary_quantity;
          a28(indx) := t(ddindx).primary_uom_code;
          a29(indx) := t(ddindx).common_quantity;
          a30(indx) := t(ddindx).common_uom_code;
          a31(indx) := t(ddindx).common_currency_code;
          a32(indx) := t(ddindx).common_amount;
          a33(indx) := t(ddindx).header_id;
          a34(indx) := t(ddindx).line_id;
          a35(indx) := t(ddindx).reason_code;
          a36(indx) := t(ddindx).source_code;
          a37(indx) := t(ddindx).error_flag;
          a38(indx) := t(ddindx).attribute_category;
          a39(indx) := t(ddindx).attribute1;
          a40(indx) := t(ddindx).attribute2;
          a41(indx) := t(ddindx).attribute3;
          a42(indx) := t(ddindx).attribute4;
          a43(indx) := t(ddindx).attribute5;
          a44(indx) := t(ddindx).attribute6;
          a45(indx) := t(ddindx).attribute7;
          a46(indx) := t(ddindx).attribute8;
          a47(indx) := t(ddindx).attribute9;
          a48(indx) := t(ddindx).attribute10;
          a49(indx) := t(ddindx).attribute11;
          a50(indx) := t(ddindx).attribute12;
          a51(indx) := t(ddindx).attribute13;
          a52(indx) := t(ddindx).attribute14;
          a53(indx) := t(ddindx).attribute15;
          a54(indx) := t(ddindx).org_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure validate_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  DATE
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  VARCHAR2
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  NUMBER
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  NUMBER
    , p6_a21  DATE
    , p6_a22  NUMBER
    , p6_a23  VARCHAR2
    , p6_a24  NUMBER
    , p6_a25  VARCHAR2
    , p6_a26  NUMBER
    , p6_a27  NUMBER
    , p6_a28  VARCHAR2
    , p6_a29  NUMBER
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  VARCHAR2
    , p6_a40  VARCHAR2
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  VARCHAR2
    , p6_a51  VARCHAR2
    , p6_a52  VARCHAR2
    , p6_a53  VARCHAR2
    , p6_a54  NUMBER
  )

  as
    ddp_transaction ozf_sales_transactions_pvt.sales_transaction_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_transaction.sales_transaction_id := p6_a0;
    ddp_transaction.object_version_number := p6_a1;
    ddp_transaction.last_update_date := p6_a2;
    ddp_transaction.last_updated_by := p6_a3;
    ddp_transaction.creation_date := p6_a4;
    ddp_transaction.request_id := p6_a5;
    ddp_transaction.created_by := p6_a6;
    ddp_transaction.created_from := p6_a7;
    ddp_transaction.last_update_login := p6_a8;
    ddp_transaction.program_application_id := p6_a9;
    ddp_transaction.program_update_date := p6_a10;
    ddp_transaction.program_id := p6_a11;
    ddp_transaction.transfer_type := p6_a12;
    ddp_transaction.sold_from_cust_account_id := p6_a13;
    ddp_transaction.sold_from_party_id := p6_a14;
    ddp_transaction.sold_from_party_site_id := p6_a15;
    ddp_transaction.sold_to_cust_account_id := p6_a16;
    ddp_transaction.sold_to_party_id := p6_a17;
    ddp_transaction.sold_to_party_site_id := p6_a18;
    ddp_transaction.bill_to_site_use_id := p6_a19;
    ddp_transaction.ship_to_site_use_id := p6_a20;
    ddp_transaction.transaction_date := p6_a21;
    ddp_transaction.quantity := p6_a22;
    ddp_transaction.uom_code := p6_a23;
    ddp_transaction.amount := p6_a24;
    ddp_transaction.currency_code := p6_a25;
    ddp_transaction.inventory_item_id := p6_a26;
    ddp_transaction.primary_quantity := p6_a27;
    ddp_transaction.primary_uom_code := p6_a28;
    ddp_transaction.common_quantity := p6_a29;
    ddp_transaction.common_uom_code := p6_a30;
    ddp_transaction.common_currency_code := p6_a31;
    ddp_transaction.common_amount := p6_a32;
    ddp_transaction.header_id := p6_a33;
    ddp_transaction.line_id := p6_a34;
    ddp_transaction.reason_code := p6_a35;
    ddp_transaction.source_code := p6_a36;
    ddp_transaction.error_flag := p6_a37;
    ddp_transaction.attribute_category := p6_a38;
    ddp_transaction.attribute1 := p6_a39;
    ddp_transaction.attribute2 := p6_a40;
    ddp_transaction.attribute3 := p6_a41;
    ddp_transaction.attribute4 := p6_a42;
    ddp_transaction.attribute5 := p6_a43;
    ddp_transaction.attribute6 := p6_a44;
    ddp_transaction.attribute7 := p6_a45;
    ddp_transaction.attribute8 := p6_a46;
    ddp_transaction.attribute9 := p6_a47;
    ddp_transaction.attribute10 := p6_a48;
    ddp_transaction.attribute11 := p6_a49;
    ddp_transaction.attribute12 := p6_a50;
    ddp_transaction.attribute13 := p6_a51;
    ddp_transaction.attribute14 := p6_a52;
    ddp_transaction.attribute15 := p6_a53;
    ddp_transaction.org_id := p6_a54;

    -- here's the delegated call to the old PL/SQL routine
    ozf_sales_transactions_pvt.validate_transaction(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_transaction);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  DATE
    , p4_a3  NUMBER
    , p4_a4  DATE
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  DATE
    , p4_a11  NUMBER
    , p4_a12  VARCHAR2
    , p4_a13  NUMBER
    , p4_a14  NUMBER
    , p4_a15  NUMBER
    , p4_a16  NUMBER
    , p4_a17  NUMBER
    , p4_a18  NUMBER
    , p4_a19  NUMBER
    , p4_a20  NUMBER
    , p4_a21  DATE
    , p4_a22  NUMBER
    , p4_a23  VARCHAR2
    , p4_a24  NUMBER
    , p4_a25  VARCHAR2
    , p4_a26  NUMBER
    , p4_a27  NUMBER
    , p4_a28  VARCHAR2
    , p4_a29  NUMBER
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  NUMBER
    , p4_a33  NUMBER
    , p4_a34  NUMBER
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p4_a37  VARCHAR2
    , p4_a38  VARCHAR2
    , p4_a39  VARCHAR2
    , p4_a40  VARCHAR2
    , p4_a41  VARCHAR2
    , p4_a42  VARCHAR2
    , p4_a43  VARCHAR2
    , p4_a44  VARCHAR2
    , p4_a45  VARCHAR2
    , p4_a46  VARCHAR2
    , p4_a47  VARCHAR2
    , p4_a48  VARCHAR2
    , p4_a49  VARCHAR2
    , p4_a50  VARCHAR2
    , p4_a51  VARCHAR2
    , p4_a52  VARCHAR2
    , p4_a53  VARCHAR2
    , p4_a54  NUMBER
    , x_sales_transaction_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddp_transaction_rec ozf_sales_transactions_pvt.sales_transaction_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_transaction_rec.sales_transaction_id := p4_a0;
    ddp_transaction_rec.object_version_number := p4_a1;
    ddp_transaction_rec.last_update_date := p4_a2;
    ddp_transaction_rec.last_updated_by := p4_a3;
    ddp_transaction_rec.creation_date := p4_a4;
    ddp_transaction_rec.request_id := p4_a5;
    ddp_transaction_rec.created_by := p4_a6;
    ddp_transaction_rec.created_from := p4_a7;
    ddp_transaction_rec.last_update_login := p4_a8;
    ddp_transaction_rec.program_application_id := p4_a9;
    ddp_transaction_rec.program_update_date := p4_a10;
    ddp_transaction_rec.program_id := p4_a11;
    ddp_transaction_rec.transfer_type := p4_a12;
    ddp_transaction_rec.sold_from_cust_account_id := p4_a13;
    ddp_transaction_rec.sold_from_party_id := p4_a14;
    ddp_transaction_rec.sold_from_party_site_id := p4_a15;
    ddp_transaction_rec.sold_to_cust_account_id := p4_a16;
    ddp_transaction_rec.sold_to_party_id := p4_a17;
    ddp_transaction_rec.sold_to_party_site_id := p4_a18;
    ddp_transaction_rec.bill_to_site_use_id := p4_a19;
    ddp_transaction_rec.ship_to_site_use_id := p4_a20;
    ddp_transaction_rec.transaction_date := p4_a21;
    ddp_transaction_rec.quantity := p4_a22;
    ddp_transaction_rec.uom_code := p4_a23;
    ddp_transaction_rec.amount := p4_a24;
    ddp_transaction_rec.currency_code := p4_a25;
    ddp_transaction_rec.inventory_item_id := p4_a26;
    ddp_transaction_rec.primary_quantity := p4_a27;
    ddp_transaction_rec.primary_uom_code := p4_a28;
    ddp_transaction_rec.common_quantity := p4_a29;
    ddp_transaction_rec.common_uom_code := p4_a30;
    ddp_transaction_rec.common_currency_code := p4_a31;
    ddp_transaction_rec.common_amount := p4_a32;
    ddp_transaction_rec.header_id := p4_a33;
    ddp_transaction_rec.line_id := p4_a34;
    ddp_transaction_rec.reason_code := p4_a35;
    ddp_transaction_rec.source_code := p4_a36;
    ddp_transaction_rec.error_flag := p4_a37;
    ddp_transaction_rec.attribute_category := p4_a38;
    ddp_transaction_rec.attribute1 := p4_a39;
    ddp_transaction_rec.attribute2 := p4_a40;
    ddp_transaction_rec.attribute3 := p4_a41;
    ddp_transaction_rec.attribute4 := p4_a42;
    ddp_transaction_rec.attribute5 := p4_a43;
    ddp_transaction_rec.attribute6 := p4_a44;
    ddp_transaction_rec.attribute7 := p4_a45;
    ddp_transaction_rec.attribute8 := p4_a46;
    ddp_transaction_rec.attribute9 := p4_a47;
    ddp_transaction_rec.attribute10 := p4_a48;
    ddp_transaction_rec.attribute11 := p4_a49;
    ddp_transaction_rec.attribute12 := p4_a50;
    ddp_transaction_rec.attribute13 := p4_a51;
    ddp_transaction_rec.attribute14 := p4_a52;
    ddp_transaction_rec.attribute15 := p4_a53;
    ddp_transaction_rec.org_id := p4_a54;





    -- here's the delegated call to the old PL/SQL routine
    ozf_sales_transactions_pvt.create_transaction(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_transaction_rec,
      x_sales_transaction_id,
      x_return_status,
      x_msg_data,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_inventory_level(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  DATE
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  VARCHAR2
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  DATE
    , p3_a11  NUMBER
    , p3_a12  NUMBER
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  DATE
    , p3_a17  VARCHAR2
    , p3_a18  NUMBER
    , p3_a19  NUMBER
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  NUMBER
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  NUMBER
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  VARCHAR2
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  VARCHAR2
    , p3_a56  VARCHAR2
    , p3_a57  VARCHAR2
    , p3_a58  NUMBER
    , p3_a59  VARCHAR2
    , p3_a60  VARCHAR2
    , p3_a61  VARCHAR2
    , p3_a62  VARCHAR2
    , p3_a63  NUMBER
    , p3_a64  NUMBER
    , p3_a65  NUMBER
    , p3_a66  NUMBER
    , p3_a67  VARCHAR2
    , p3_a68  VARCHAR2
    , p3_a69  VARCHAR2
    , p3_a70  VARCHAR2
    , p3_a71  VARCHAR2
    , p3_a72  VARCHAR2
    , p3_a73  VARCHAR2
    , p3_a74  VARCHAR2
    , p3_a75  NUMBER
    , p3_a76  VARCHAR2
    , p3_a77  VARCHAR2
    , p3_a78  VARCHAR2
    , p3_a79  VARCHAR2
    , p3_a80  NUMBER
    , p3_a81  NUMBER
    , p3_a82  VARCHAR2
    , p3_a83  NUMBER
    , p3_a84  VARCHAR2
    , p3_a85  VARCHAR2
    , p3_a86  VARCHAR2
    , p3_a87  VARCHAR2
    , p3_a88  VARCHAR2
    , p3_a89  VARCHAR2
    , p3_a90  VARCHAR2
    , p3_a91  NUMBER
    , p3_a92  VARCHAR2
    , p3_a93  VARCHAR2
    , p3_a94  VARCHAR2
    , p3_a95  VARCHAR2
    , p3_a96  VARCHAR2
    , p3_a97  NUMBER
    , p3_a98  VARCHAR2
    , p3_a99  VARCHAR2
    , p3_a100  VARCHAR2
    , p3_a101  NUMBER
    , p3_a102  VARCHAR2
    , p3_a103  NUMBER
    , p3_a104  VARCHAR2
    , p3_a105  NUMBER
    , p3_a106  VARCHAR2
    , p3_a107  NUMBER
    , p3_a108  VARCHAR2
    , p3_a109  VARCHAR2
    , p3_a110  VARCHAR2
    , p3_a111  VARCHAR2
    , p3_a112  NUMBER
    , p3_a113  NUMBER
    , p3_a114  VARCHAR2
    , p3_a115  VARCHAR2
    , p3_a116  VARCHAR2
    , p3_a117  NUMBER
    , p3_a118  NUMBER
    , p3_a119  VARCHAR2
    , p3_a120  VARCHAR2
    , p3_a121  VARCHAR2
    , p3_a122  VARCHAR2
    , p3_a123  VARCHAR2
    , p3_a124  NUMBER
    , p3_a125  NUMBER
    , p3_a126  VARCHAR2
    , p3_a127  VARCHAR2
    , p3_a128  NUMBER
    , p3_a129  VARCHAR2
    , p3_a130  DATE
    , p3_a131  VARCHAR2
    , p3_a132  VARCHAR2
    , p3_a133  VARCHAR2
    , p3_a134  VARCHAR2
    , p3_a135  DATE
    , p3_a136  VARCHAR2
    , p3_a137  DATE
    , p3_a138  DATE
    , p3_a139  NUMBER
    , p3_a140  NUMBER
    , p3_a141  NUMBER
    , p3_a142  NUMBER
    , p3_a143  NUMBER
    , p3_a144  NUMBER
    , p3_a145  VARCHAR2
    , p3_a146  NUMBER
    , p3_a147  NUMBER
    , p3_a148  VARCHAR2
    , p3_a149  NUMBER
    , p3_a150  NUMBER
    , p3_a151  NUMBER
    , p3_a152  VARCHAR2
    , p3_a153  NUMBER
    , p3_a154  NUMBER
    , p3_a155  NUMBER
    , p3_a156  NUMBER
    , p3_a157  VARCHAR2
    , p3_a158  DATE
    , p3_a159  VARCHAR2
    , p3_a160  NUMBER
    , p3_a161  VARCHAR2
    , p3_a162  VARCHAR2
    , p3_a163  VARCHAR2
    , p3_a164  VARCHAR2
    , p3_a165  VARCHAR2
    , p3_a166  VARCHAR2
    , p3_a167  VARCHAR2
    , p3_a168  VARCHAR2
    , p3_a169  VARCHAR2
    , p3_a170  VARCHAR2
    , p3_a171  VARCHAR2
    , p3_a172  VARCHAR2
    , p3_a173  VARCHAR2
    , p3_a174  VARCHAR2
    , p3_a175  VARCHAR2
    , p3_a176  VARCHAR2
    , p3_a177  VARCHAR2
    , p3_a178  VARCHAR2
    , p3_a179  VARCHAR2
    , p3_a180  VARCHAR2
    , p3_a181  VARCHAR2
    , p3_a182  VARCHAR2
    , p3_a183  NUMBER
    , p3_a184  VARCHAR2
    , p3_a185  NUMBER
    , p3_a186  NUMBER
    , p3_a187  VARCHAR2
    , p3_a188  VARCHAR2
    , p3_a189  VARCHAR2
    , p3_a190  VARCHAR2
    , p3_a191  NUMBER
    , p3_a192  VARCHAR2
    , p3_a193  VARCHAR2
    , p3_a194  VARCHAR2
    , p3_a195  VARCHAR2
    , p3_a196  VARCHAR2
    , p3_a197  VARCHAR2
    , p3_a198  VARCHAR2
    , p3_a199  VARCHAR2
    , p3_a200  VARCHAR2
    , p3_a201  VARCHAR2
    , p3_a202  VARCHAR2
    , p3_a203  VARCHAR2
    , p3_a204  VARCHAR2
    , p3_a205  VARCHAR2
    , p3_a206  VARCHAR2
    , p3_a207  VARCHAR2
    , p3_a208  VARCHAR2
    , p3_a209  VARCHAR2
    , p3_a210  VARCHAR2
    , p3_a211  VARCHAR2
    , p3_a212  VARCHAR2
    , p3_a213  VARCHAR2
    , p3_a214  VARCHAR2
    , p3_a215  VARCHAR2
    , p3_a216  VARCHAR2
    , p3_a217  VARCHAR2
    , p3_a218  VARCHAR2
    , p3_a219  VARCHAR2
    , p3_a220  VARCHAR2
    , p3_a221  VARCHAR2
    , p3_a222  VARCHAR2
    , p3_a223  VARCHAR2
    , p3_a224  VARCHAR2
    , p3_a225  NUMBER
    , x_valid out nocopy  number
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_line_int_rec ozf_resale_common_pvt.g_interface_rec_csr%rowtype;
    ddx_valid boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_line_int_rec.resale_line_int_id := p3_a0;
    ddp_line_int_rec.object_version_number := p3_a1;
    ddp_line_int_rec.last_update_date := p3_a2;
    ddp_line_int_rec.last_updated_by := p3_a3;
    ddp_line_int_rec.creation_date := p3_a4;
    ddp_line_int_rec.request_id := p3_a5;
    ddp_line_int_rec.created_by := p3_a6;
    ddp_line_int_rec.created_from := p3_a7;
    ddp_line_int_rec.last_update_login := p3_a8;
    ddp_line_int_rec.program_application_id := p3_a9;
    ddp_line_int_rec.program_update_date := p3_a10;
    ddp_line_int_rec.program_id := p3_a11;
    ddp_line_int_rec.resale_batch_id := p3_a12;
    ddp_line_int_rec.status_code := p3_a13;
    ddp_line_int_rec.resale_transfer_type := p3_a14;
    ddp_line_int_rec.product_transfer_movement_type := p3_a15;
    ddp_line_int_rec.product_transfer_date := p3_a16;
    ddp_line_int_rec.tracing_flag := p3_a17;
    ddp_line_int_rec.ship_from_cust_account_id := p3_a18;
    ddp_line_int_rec.ship_from_site_id := p3_a19;
    ddp_line_int_rec.ship_from_party_name := p3_a20;
    ddp_line_int_rec.ship_from_location := p3_a21;
    ddp_line_int_rec.ship_from_address := p3_a22;
    ddp_line_int_rec.ship_from_city := p3_a23;
    ddp_line_int_rec.ship_from_state := p3_a24;
    ddp_line_int_rec.ship_from_postal_code := p3_a25;
    ddp_line_int_rec.ship_from_country := p3_a26;
    ddp_line_int_rec.ship_from_contact_party_id := p3_a27;
    ddp_line_int_rec.ship_from_contact_name := p3_a28;
    ddp_line_int_rec.ship_from_email := p3_a29;
    ddp_line_int_rec.ship_from_fax := p3_a30;
    ddp_line_int_rec.ship_from_phone := p3_a31;
    ddp_line_int_rec.sold_from_cust_account_id := p3_a32;
    ddp_line_int_rec.sold_from_site_id := p3_a33;
    ddp_line_int_rec.sold_from_party_name := p3_a34;
    ddp_line_int_rec.sold_from_location := p3_a35;
    ddp_line_int_rec.sold_from_address := p3_a36;
    ddp_line_int_rec.sold_from_city := p3_a37;
    ddp_line_int_rec.sold_from_state := p3_a38;
    ddp_line_int_rec.sold_from_postal_code := p3_a39;
    ddp_line_int_rec.sold_from_country := p3_a40;
    ddp_line_int_rec.sold_from_contact_party_id := p3_a41;
    ddp_line_int_rec.sold_from_contact_name := p3_a42;
    ddp_line_int_rec.sold_from_email := p3_a43;
    ddp_line_int_rec.sold_from_phone := p3_a44;
    ddp_line_int_rec.sold_from_fax := p3_a45;
    ddp_line_int_rec.bill_to_cust_account_id := p3_a46;
    ddp_line_int_rec.bill_to_site_use_id := p3_a47;
    ddp_line_int_rec.bill_to_party_id := p3_a48;
    ddp_line_int_rec.bill_to_party_site_id := p3_a49;
    ddp_line_int_rec.bill_to_party_name := p3_a50;
    ddp_line_int_rec.bill_to_duns_number := p3_a51;
    ddp_line_int_rec.bill_to_location := p3_a52;
    ddp_line_int_rec.bill_to_address := p3_a53;
    ddp_line_int_rec.bill_to_city := p3_a54;
    ddp_line_int_rec.bill_to_state := p3_a55;
    ddp_line_int_rec.bill_to_postal_code := p3_a56;
    ddp_line_int_rec.bill_to_country := p3_a57;
    ddp_line_int_rec.bill_to_contact_party_id := p3_a58;
    ddp_line_int_rec.bill_to_contact_name := p3_a59;
    ddp_line_int_rec.bill_to_email := p3_a60;
    ddp_line_int_rec.bill_to_phone := p3_a61;
    ddp_line_int_rec.bill_to_fax := p3_a62;
    ddp_line_int_rec.ship_to_cust_account_id := p3_a63;
    ddp_line_int_rec.ship_to_site_use_id := p3_a64;
    ddp_line_int_rec.ship_to_party_id := p3_a65;
    ddp_line_int_rec.ship_to_party_site_id := p3_a66;
    ddp_line_int_rec.ship_to_party_name := p3_a67;
    ddp_line_int_rec.ship_to_duns_number := p3_a68;
    ddp_line_int_rec.ship_to_location := p3_a69;
    ddp_line_int_rec.ship_to_address := p3_a70;
    ddp_line_int_rec.ship_to_city := p3_a71;
    ddp_line_int_rec.ship_to_country := p3_a72;
    ddp_line_int_rec.ship_to_postal_code := p3_a73;
    ddp_line_int_rec.ship_to_state := p3_a74;
    ddp_line_int_rec.ship_to_contact_party_id := p3_a75;
    ddp_line_int_rec.ship_to_contact_name := p3_a76;
    ddp_line_int_rec.ship_to_email := p3_a77;
    ddp_line_int_rec.ship_to_phone := p3_a78;
    ddp_line_int_rec.ship_to_fax := p3_a79;
    ddp_line_int_rec.end_cust_party_id := p3_a80;
    ddp_line_int_rec.end_cust_site_use_id := p3_a81;
    ddp_line_int_rec.end_cust_site_use_code := p3_a82;
    ddp_line_int_rec.end_cust_party_site_id := p3_a83;
    ddp_line_int_rec.end_cust_party_name := p3_a84;
    ddp_line_int_rec.end_cust_location := p3_a85;
    ddp_line_int_rec.end_cust_address := p3_a86;
    ddp_line_int_rec.end_cust_city := p3_a87;
    ddp_line_int_rec.end_cust_state := p3_a88;
    ddp_line_int_rec.end_cust_postal_code := p3_a89;
    ddp_line_int_rec.end_cust_country := p3_a90;
    ddp_line_int_rec.end_cust_contact_party_id := p3_a91;
    ddp_line_int_rec.end_cust_contact_name := p3_a92;
    ddp_line_int_rec.end_cust_email := p3_a93;
    ddp_line_int_rec.end_cust_phone := p3_a94;
    ddp_line_int_rec.end_cust_fax := p3_a95;
    ddp_line_int_rec.direct_customer_flag := p3_a96;
    ddp_line_int_rec.order_type_id := p3_a97;
    ddp_line_int_rec.order_type := p3_a98;
    ddp_line_int_rec.order_category := p3_a99;
    ddp_line_int_rec.agreement_type := p3_a100;
    ddp_line_int_rec.agreement_id := p3_a101;
    ddp_line_int_rec.agreement_name := p3_a102;
    ddp_line_int_rec.agreement_price := p3_a103;
    ddp_line_int_rec.agreement_uom_code := p3_a104;
    ddp_line_int_rec.corrected_agreement_id := p3_a105;
    ddp_line_int_rec.corrected_agreement_name := p3_a106;
    ddp_line_int_rec.price_list_id := p3_a107;
    ddp_line_int_rec.price_list_name := p3_a108;
    ddp_line_int_rec.orig_system_reference := p3_a109;
    ddp_line_int_rec.orig_system_line_reference := p3_a110;
    ddp_line_int_rec.orig_system_currency_code := p3_a111;
    ddp_line_int_rec.orig_system_selling_price := p3_a112;
    ddp_line_int_rec.orig_system_quantity := p3_a113;
    ddp_line_int_rec.orig_system_uom := p3_a114;
    ddp_line_int_rec.orig_system_purchase_uom := p3_a115;
    ddp_line_int_rec.orig_system_purchase_curr := p3_a116;
    ddp_line_int_rec.orig_system_purchase_price := p3_a117;
    ddp_line_int_rec.orig_system_purchase_quantity := p3_a118;
    ddp_line_int_rec.orig_system_agreement_uom := p3_a119;
    ddp_line_int_rec.orig_system_agreement_name := p3_a120;
    ddp_line_int_rec.orig_system_agreement_type := p3_a121;
    ddp_line_int_rec.orig_system_agreement_status := p3_a122;
    ddp_line_int_rec.orig_system_agreement_curr := p3_a123;
    ddp_line_int_rec.orig_system_agreement_price := p3_a124;
    ddp_line_int_rec.orig_system_agreement_quantity := p3_a125;
    ddp_line_int_rec.orig_system_item_number := p3_a126;
    ddp_line_int_rec.currency_code := p3_a127;
    ddp_line_int_rec.exchange_rate := p3_a128;
    ddp_line_int_rec.exchange_rate_type := p3_a129;
    ddp_line_int_rec.exchange_rate_date := p3_a130;
    ddp_line_int_rec.po_number := p3_a131;
    ddp_line_int_rec.po_release_number := p3_a132;
    ddp_line_int_rec.po_type := p3_a133;
    ddp_line_int_rec.invoice_number := p3_a134;
    ddp_line_int_rec.date_invoiced := p3_a135;
    ddp_line_int_rec.order_number := p3_a136;
    ddp_line_int_rec.date_ordered := p3_a137;
    ddp_line_int_rec.date_shipped := p3_a138;
    ddp_line_int_rec.claimed_amount := p3_a139;
    ddp_line_int_rec.allowed_amount := p3_a140;
    ddp_line_int_rec.total_allowed_amount := p3_a141;
    ddp_line_int_rec.accepted_amount := p3_a142;
    ddp_line_int_rec.total_accepted_amount := p3_a143;
    ddp_line_int_rec.line_tolerance_amount := p3_a144;
    ddp_line_int_rec.tolerance_flag := p3_a145;
    ddp_line_int_rec.total_claimed_amount := p3_a146;
    ddp_line_int_rec.purchase_price := p3_a147;
    ddp_line_int_rec.purchase_uom_code := p3_a148;
    ddp_line_int_rec.acctd_purchase_price := p3_a149;
    ddp_line_int_rec.selling_price := p3_a150;
    ddp_line_int_rec.acctd_selling_price := p3_a151;
    ddp_line_int_rec.uom_code := p3_a152;
    ddp_line_int_rec.quantity := p3_a153;
    ddp_line_int_rec.calculated_price := p3_a154;
    ddp_line_int_rec.acctd_calculated_price := p3_a155;
    ddp_line_int_rec.calculated_amount := p3_a156;
    ddp_line_int_rec.credit_code := p3_a157;
    ddp_line_int_rec.credit_advice_date := p3_a158;
    ddp_line_int_rec.upc_code := p3_a159;
    ddp_line_int_rec.inventory_item_id := p3_a160;
    ddp_line_int_rec.item_number := p3_a161;
    ddp_line_int_rec.item_description := p3_a162;
    ddp_line_int_rec.inventory_item_segment1 := p3_a163;
    ddp_line_int_rec.inventory_item_segment2 := p3_a164;
    ddp_line_int_rec.inventory_item_segment3 := p3_a165;
    ddp_line_int_rec.inventory_item_segment4 := p3_a166;
    ddp_line_int_rec.inventory_item_segment5 := p3_a167;
    ddp_line_int_rec.inventory_item_segment6 := p3_a168;
    ddp_line_int_rec.inventory_item_segment7 := p3_a169;
    ddp_line_int_rec.inventory_item_segment8 := p3_a170;
    ddp_line_int_rec.inventory_item_segment9 := p3_a171;
    ddp_line_int_rec.inventory_item_segment10 := p3_a172;
    ddp_line_int_rec.inventory_item_segment11 := p3_a173;
    ddp_line_int_rec.inventory_item_segment12 := p3_a174;
    ddp_line_int_rec.inventory_item_segment13 := p3_a175;
    ddp_line_int_rec.inventory_item_segment14 := p3_a176;
    ddp_line_int_rec.inventory_item_segment15 := p3_a177;
    ddp_line_int_rec.inventory_item_segment16 := p3_a178;
    ddp_line_int_rec.inventory_item_segment17 := p3_a179;
    ddp_line_int_rec.inventory_item_segment18 := p3_a180;
    ddp_line_int_rec.inventory_item_segment19 := p3_a181;
    ddp_line_int_rec.inventory_item_segment20 := p3_a182;
    ddp_line_int_rec.product_category_id := p3_a183;
    ddp_line_int_rec.category_name := p3_a184;
    ddp_line_int_rec.duplicated_line_id := p3_a185;
    ddp_line_int_rec.duplicated_adjustment_id := p3_a186;
    ddp_line_int_rec.response_type := p3_a187;
    ddp_line_int_rec.response_code := p3_a188;
    ddp_line_int_rec.reject_reason_code := p3_a189;
    ddp_line_int_rec.followup_action_code := p3_a190;
    ddp_line_int_rec.net_adjusted_amount := p3_a191;
    ddp_line_int_rec.dispute_code := p3_a192;
    ddp_line_int_rec.header_attribute_category := p3_a193;
    ddp_line_int_rec.header_attribute1 := p3_a194;
    ddp_line_int_rec.header_attribute2 := p3_a195;
    ddp_line_int_rec.header_attribute3 := p3_a196;
    ddp_line_int_rec.header_attribute4 := p3_a197;
    ddp_line_int_rec.header_attribute5 := p3_a198;
    ddp_line_int_rec.header_attribute6 := p3_a199;
    ddp_line_int_rec.header_attribute7 := p3_a200;
    ddp_line_int_rec.header_attribute8 := p3_a201;
    ddp_line_int_rec.header_attribute9 := p3_a202;
    ddp_line_int_rec.header_attribute10 := p3_a203;
    ddp_line_int_rec.header_attribute11 := p3_a204;
    ddp_line_int_rec.header_attribute12 := p3_a205;
    ddp_line_int_rec.header_attribute13 := p3_a206;
    ddp_line_int_rec.header_attribute14 := p3_a207;
    ddp_line_int_rec.header_attribute15 := p3_a208;
    ddp_line_int_rec.line_attribute_category := p3_a209;
    ddp_line_int_rec.line_attribute1 := p3_a210;
    ddp_line_int_rec.line_attribute2 := p3_a211;
    ddp_line_int_rec.line_attribute3 := p3_a212;
    ddp_line_int_rec.line_attribute4 := p3_a213;
    ddp_line_int_rec.line_attribute5 := p3_a214;
    ddp_line_int_rec.line_attribute6 := p3_a215;
    ddp_line_int_rec.line_attribute7 := p3_a216;
    ddp_line_int_rec.line_attribute8 := p3_a217;
    ddp_line_int_rec.line_attribute9 := p3_a218;
    ddp_line_int_rec.line_attribute10 := p3_a219;
    ddp_line_int_rec.line_attribute11 := p3_a220;
    ddp_line_int_rec.line_attribute12 := p3_a221;
    ddp_line_int_rec.line_attribute13 := p3_a222;
    ddp_line_int_rec.line_attribute14 := p3_a223;
    ddp_line_int_rec.line_attribute15 := p3_a224;
    ddp_line_int_rec.org_id := p3_a225;





    -- here's the delegated call to the old PL/SQL routine
    ozf_sales_transactions_pvt.validate_inventory_level(p_api_version,
      p_init_msg_list,
      p_validation_level,
      ddp_line_int_rec,
      ddx_valid,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  if ddx_valid is null
    then x_valid := null;
  elsif ddx_valid
    then x_valid := 1;
  else x_valid := 0;
  end if;



  end;

end ozf_sales_transactions_pvt_w;

/
