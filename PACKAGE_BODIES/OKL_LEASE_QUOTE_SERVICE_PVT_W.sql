--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_SERVICE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_SERVICE_PVT_W" as
  /* $Header: OKLEQUSB.pls 120.2 2006/02/13 07:28:44 asawanka noship $ */
  procedure rosetta_table_copy_in_p17(t out nocopy okl_lease_quote_service_pvt.line_relation_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).source_line_type := a2(indx);
          t(ddindx).source_line_id := a3(indx);
          t(ddindx).related_line_type := a4(indx);
          t(ddindx).related_line_id := a5(indx);
          t(ddindx).amount := a6(indx);
          t(ddindx).short_description := a7(indx);
          t(ddindx).description := a8(indx);
          t(ddindx).comments := a9(indx);
          t(ddindx).record_mode := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p17;
  procedure rosetta_table_copy_out_p17(t okl_lease_quote_service_pvt.line_relation_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_300();
    a8 := JTF_VARCHAR2_TABLE_2000();
    a9 := JTF_VARCHAR2_TABLE_2000();
    a10 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_300();
      a8 := JTF_VARCHAR2_TABLE_2000();
      a9 := JTF_VARCHAR2_TABLE_2000();
      a10 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).source_line_type;
          a3(indx) := t(ddindx).source_line_id;
          a4(indx) := t(ddindx).related_line_type;
          a5(indx) := t(ddindx).related_line_id;
          a6(indx) := t(ddindx).amount;
          a7(indx) := t(ddindx).short_description;
          a8(indx) := t(ddindx).description;
          a9(indx) := t(ddindx).comments;
          a10(indx) := t(ddindx).record_mode;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p17;

  procedure create_service(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  NUMBER
    , p3_a19  VARCHAR2
    , p3_a20  NUMBER
    , p3_a21  DATE
    , p3_a22  NUMBER
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_300
    , p4_a8 JTF_VARCHAR2_TABLE_2000
    , p4_a9 JTF_VARCHAR2_TABLE_2000
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p5_a0  VARCHAR2
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_DATE_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p7_a0  VARCHAR2
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_DATE_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_NUMBER_TABLE
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , x_service_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_service_rec okl_svc_pvt.svcv_rec_type;
    ddp_assoc_asset_tbl okl_lease_quote_service_pvt.line_relation_tbl_type;
    ddp_payment_header_rec okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    ddp_payment_level_tbl okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;
    ddp_expense_header_rec okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    ddp_expense_level_tbl okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_service_rec.id := p3_a0;
    ddp_service_rec.object_version_number := p3_a1;
    ddp_service_rec.attribute_category := p3_a2;
    ddp_service_rec.attribute1 := p3_a3;
    ddp_service_rec.attribute2 := p3_a4;
    ddp_service_rec.attribute3 := p3_a5;
    ddp_service_rec.attribute4 := p3_a6;
    ddp_service_rec.attribute5 := p3_a7;
    ddp_service_rec.attribute6 := p3_a8;
    ddp_service_rec.attribute7 := p3_a9;
    ddp_service_rec.attribute8 := p3_a10;
    ddp_service_rec.attribute9 := p3_a11;
    ddp_service_rec.attribute10 := p3_a12;
    ddp_service_rec.attribute11 := p3_a13;
    ddp_service_rec.attribute12 := p3_a14;
    ddp_service_rec.attribute13 := p3_a15;
    ddp_service_rec.attribute14 := p3_a16;
    ddp_service_rec.attribute15 := p3_a17;
    ddp_service_rec.inv_item_id := p3_a18;
    ddp_service_rec.parent_object_code := p3_a19;
    ddp_service_rec.parent_object_id := p3_a20;
    ddp_service_rec.effective_from := p3_a21;
    ddp_service_rec.supplier_id := p3_a22;
    ddp_service_rec.short_description := p3_a23;
    ddp_service_rec.description := p3_a24;
    ddp_service_rec.comments := p3_a25;

    okl_lease_quote_service_pvt_w.rosetta_table_copy_in_p17(ddp_assoc_asset_tbl, p4_a0
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
      );

    ddp_payment_header_rec.type_code := p5_a0;
    ddp_payment_header_rec.stream_type_id := p5_a1;
    ddp_payment_header_rec.status_code := p5_a2;
    ddp_payment_header_rec.arrears_flag := p5_a3;
    ddp_payment_header_rec.frequency_code := p5_a4;
    ddp_payment_header_rec.dnz_periods := p5_a5;
    ddp_payment_header_rec.dnz_periodic_amount := p5_a6;
    ddp_payment_header_rec.parent_object_code := p5_a7;
    ddp_payment_header_rec.parent_object_id := p5_a8;
    ddp_payment_header_rec.quote_type_code := p5_a9;
    ddp_payment_header_rec.quote_id := p5_a10;
    ddp_payment_header_rec.cashflow_header_id := p5_a11;
    ddp_payment_header_rec.cashflow_object_id := p5_a12;
    ddp_payment_header_rec.cashflow_header_ovn := p5_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_payment_level_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );

    ddp_expense_header_rec.type_code := p7_a0;
    ddp_expense_header_rec.stream_type_id := p7_a1;
    ddp_expense_header_rec.status_code := p7_a2;
    ddp_expense_header_rec.arrears_flag := p7_a3;
    ddp_expense_header_rec.frequency_code := p7_a4;
    ddp_expense_header_rec.dnz_periods := p7_a5;
    ddp_expense_header_rec.dnz_periodic_amount := p7_a6;
    ddp_expense_header_rec.parent_object_code := p7_a7;
    ddp_expense_header_rec.parent_object_id := p7_a8;
    ddp_expense_header_rec.quote_type_code := p7_a9;
    ddp_expense_header_rec.quote_id := p7_a10;
    ddp_expense_header_rec.cashflow_header_id := p7_a11;
    ddp_expense_header_rec.cashflow_object_id := p7_a12;
    ddp_expense_header_rec.cashflow_header_ovn := p7_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_expense_level_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      );





    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_service_pvt.create_service(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_service_rec,
      ddp_assoc_asset_tbl,
      ddp_payment_header_rec,
      ddp_payment_level_tbl,
      ddp_expense_header_rec,
      ddp_expense_level_tbl,
      x_service_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure update_service(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  NUMBER
    , p3_a19  VARCHAR2
    , p3_a20  NUMBER
    , p3_a21  DATE
    , p3_a22  NUMBER
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_300
    , p4_a8 JTF_VARCHAR2_TABLE_2000
    , p4_a9 JTF_VARCHAR2_TABLE_2000
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p5_a0  VARCHAR2
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_DATE_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p7_a0  VARCHAR2
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_DATE_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_NUMBER_TABLE
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_service_rec okl_svc_pvt.svcv_rec_type;
    ddp_assoc_asset_tbl okl_lease_quote_service_pvt.line_relation_tbl_type;
    ddp_payment_header_rec okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    ddp_payment_level_tbl okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;
    ddp_expense_header_rec okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    ddp_expense_level_tbl okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_service_rec.id := p3_a0;
    ddp_service_rec.object_version_number := p3_a1;
    ddp_service_rec.attribute_category := p3_a2;
    ddp_service_rec.attribute1 := p3_a3;
    ddp_service_rec.attribute2 := p3_a4;
    ddp_service_rec.attribute3 := p3_a5;
    ddp_service_rec.attribute4 := p3_a6;
    ddp_service_rec.attribute5 := p3_a7;
    ddp_service_rec.attribute6 := p3_a8;
    ddp_service_rec.attribute7 := p3_a9;
    ddp_service_rec.attribute8 := p3_a10;
    ddp_service_rec.attribute9 := p3_a11;
    ddp_service_rec.attribute10 := p3_a12;
    ddp_service_rec.attribute11 := p3_a13;
    ddp_service_rec.attribute12 := p3_a14;
    ddp_service_rec.attribute13 := p3_a15;
    ddp_service_rec.attribute14 := p3_a16;
    ddp_service_rec.attribute15 := p3_a17;
    ddp_service_rec.inv_item_id := p3_a18;
    ddp_service_rec.parent_object_code := p3_a19;
    ddp_service_rec.parent_object_id := p3_a20;
    ddp_service_rec.effective_from := p3_a21;
    ddp_service_rec.supplier_id := p3_a22;
    ddp_service_rec.short_description := p3_a23;
    ddp_service_rec.description := p3_a24;
    ddp_service_rec.comments := p3_a25;

    okl_lease_quote_service_pvt_w.rosetta_table_copy_in_p17(ddp_assoc_asset_tbl, p4_a0
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
      );

    ddp_payment_header_rec.type_code := p5_a0;
    ddp_payment_header_rec.stream_type_id := p5_a1;
    ddp_payment_header_rec.status_code := p5_a2;
    ddp_payment_header_rec.arrears_flag := p5_a3;
    ddp_payment_header_rec.frequency_code := p5_a4;
    ddp_payment_header_rec.dnz_periods := p5_a5;
    ddp_payment_header_rec.dnz_periodic_amount := p5_a6;
    ddp_payment_header_rec.parent_object_code := p5_a7;
    ddp_payment_header_rec.parent_object_id := p5_a8;
    ddp_payment_header_rec.quote_type_code := p5_a9;
    ddp_payment_header_rec.quote_id := p5_a10;
    ddp_payment_header_rec.cashflow_header_id := p5_a11;
    ddp_payment_header_rec.cashflow_object_id := p5_a12;
    ddp_payment_header_rec.cashflow_header_ovn := p5_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_payment_level_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      );

    ddp_expense_header_rec.type_code := p7_a0;
    ddp_expense_header_rec.stream_type_id := p7_a1;
    ddp_expense_header_rec.status_code := p7_a2;
    ddp_expense_header_rec.arrears_flag := p7_a3;
    ddp_expense_header_rec.frequency_code := p7_a4;
    ddp_expense_header_rec.dnz_periods := p7_a5;
    ddp_expense_header_rec.dnz_periodic_amount := p7_a6;
    ddp_expense_header_rec.parent_object_code := p7_a7;
    ddp_expense_header_rec.parent_object_id := p7_a8;
    ddp_expense_header_rec.quote_type_code := p7_a9;
    ddp_expense_header_rec.quote_id := p7_a10;
    ddp_expense_header_rec.cashflow_header_id := p7_a11;
    ddp_expense_header_rec.cashflow_object_id := p7_a12;
    ddp_expense_header_rec.cashflow_header_ovn := p7_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_expense_level_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_service_pvt.update_service(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_service_rec,
      ddp_assoc_asset_tbl,
      ddp_payment_header_rec,
      ddp_payment_level_tbl,
      ddp_expense_header_rec,
      ddp_expense_level_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure duplicate_service(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p_source_service_id  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  NUMBER
    , p4_a19  VARCHAR2
    , p4_a20  NUMBER
    , p4_a21  DATE
    , p4_a22  NUMBER
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_300
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p6_a0  VARCHAR2
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  VARCHAR2
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_DATE_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p8_a0  VARCHAR2
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  NUMBER
    , p8_a11  NUMBER
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_DATE_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_100
    , x_service_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_service_rec okl_svc_pvt.svcv_rec_type;
    ddp_assoc_asset_tbl okl_lease_quote_service_pvt.line_relation_tbl_type;
    ddp_payment_header_rec okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    ddp_payment_level_tbl okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;
    ddp_expense_header_rec okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    ddp_expense_level_tbl okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_service_rec.id := p4_a0;
    ddp_service_rec.object_version_number := p4_a1;
    ddp_service_rec.attribute_category := p4_a2;
    ddp_service_rec.attribute1 := p4_a3;
    ddp_service_rec.attribute2 := p4_a4;
    ddp_service_rec.attribute3 := p4_a5;
    ddp_service_rec.attribute4 := p4_a6;
    ddp_service_rec.attribute5 := p4_a7;
    ddp_service_rec.attribute6 := p4_a8;
    ddp_service_rec.attribute7 := p4_a9;
    ddp_service_rec.attribute8 := p4_a10;
    ddp_service_rec.attribute9 := p4_a11;
    ddp_service_rec.attribute10 := p4_a12;
    ddp_service_rec.attribute11 := p4_a13;
    ddp_service_rec.attribute12 := p4_a14;
    ddp_service_rec.attribute13 := p4_a15;
    ddp_service_rec.attribute14 := p4_a16;
    ddp_service_rec.attribute15 := p4_a17;
    ddp_service_rec.inv_item_id := p4_a18;
    ddp_service_rec.parent_object_code := p4_a19;
    ddp_service_rec.parent_object_id := p4_a20;
    ddp_service_rec.effective_from := p4_a21;
    ddp_service_rec.supplier_id := p4_a22;
    ddp_service_rec.short_description := p4_a23;
    ddp_service_rec.description := p4_a24;
    ddp_service_rec.comments := p4_a25;

    okl_lease_quote_service_pvt_w.rosetta_table_copy_in_p17(ddp_assoc_asset_tbl, p5_a0
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
      );

    ddp_payment_header_rec.type_code := p6_a0;
    ddp_payment_header_rec.stream_type_id := p6_a1;
    ddp_payment_header_rec.status_code := p6_a2;
    ddp_payment_header_rec.arrears_flag := p6_a3;
    ddp_payment_header_rec.frequency_code := p6_a4;
    ddp_payment_header_rec.dnz_periods := p6_a5;
    ddp_payment_header_rec.dnz_periodic_amount := p6_a6;
    ddp_payment_header_rec.parent_object_code := p6_a7;
    ddp_payment_header_rec.parent_object_id := p6_a8;
    ddp_payment_header_rec.quote_type_code := p6_a9;
    ddp_payment_header_rec.quote_id := p6_a10;
    ddp_payment_header_rec.cashflow_header_id := p6_a11;
    ddp_payment_header_rec.cashflow_object_id := p6_a12;
    ddp_payment_header_rec.cashflow_header_ovn := p6_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_payment_level_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      );

    ddp_expense_header_rec.type_code := p8_a0;
    ddp_expense_header_rec.stream_type_id := p8_a1;
    ddp_expense_header_rec.status_code := p8_a2;
    ddp_expense_header_rec.arrears_flag := p8_a3;
    ddp_expense_header_rec.frequency_code := p8_a4;
    ddp_expense_header_rec.dnz_periods := p8_a5;
    ddp_expense_header_rec.dnz_periodic_amount := p8_a6;
    ddp_expense_header_rec.parent_object_code := p8_a7;
    ddp_expense_header_rec.parent_object_id := p8_a8;
    ddp_expense_header_rec.quote_type_code := p8_a9;
    ddp_expense_header_rec.quote_id := p8_a10;
    ddp_expense_header_rec.cashflow_header_id := p8_a11;
    ddp_expense_header_rec.cashflow_object_id := p8_a12;
    ddp_expense_header_rec.cashflow_header_ovn := p8_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_expense_level_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      );





    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_service_pvt.duplicate_service(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      p_source_service_id,
      ddp_service_rec,
      ddp_assoc_asset_tbl,
      ddp_payment_header_rec,
      ddp_payment_level_tbl,
      ddp_expense_header_rec,
      ddp_expense_level_tbl,
      x_service_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

end okl_lease_quote_service_pvt_w;

/
