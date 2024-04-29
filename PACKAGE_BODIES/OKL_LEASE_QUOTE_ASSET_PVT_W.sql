--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_ASSET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_ASSET_PVT_W" as
  /* $Header: OKLEQUAB.pls 120.15.12010000.2 2010/04/30 15:26:38 rpillay ship $ */
  procedure rosetta_table_copy_in_p26(t out nocopy okl_lease_quote_asset_pvt.asset_component_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_400
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_2000
    , a13 JTF_VARCHAR2_TABLE_2000
    , a14 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).asset_id := a2(indx);
          t(ddindx).inv_item_id := a3(indx);
          t(ddindx).supplier_id := a4(indx);
          t(ddindx).primary_component := a5(indx);
          t(ddindx).unit_cost := a6(indx);
          t(ddindx).number_of_units := a7(indx);
          t(ddindx).manufacturer_name := a8(indx);
          t(ddindx).year_manufactured := a9(indx);
          t(ddindx).model_number := a10(indx);
          t(ddindx).short_description := a11(indx);
          t(ddindx).description := a12(indx);
          t(ddindx).comments := a13(indx);
          t(ddindx).record_mode := a14(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t okl_lease_quote_asset_pvt.asset_component_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_400
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_VARCHAR2_TABLE_2000
    , a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    a8 := JTF_VARCHAR2_TABLE_400();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_2000();
    a13 := JTF_VARCHAR2_TABLE_2000();
    a14 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_400();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_2000();
      a13 := JTF_VARCHAR2_TABLE_2000();
      a14 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).asset_id;
          a3(indx) := t(ddindx).inv_item_id;
          a4(indx) := t(ddindx).supplier_id;
          a5(indx) := t(ddindx).primary_component;
          a6(indx) := t(ddindx).unit_cost;
          a7(indx) := t(ddindx).number_of_units;
          a8(indx) := t(ddindx).manufacturer_name;
          a9(indx) := t(ddindx).year_manufactured;
          a10(indx) := t(ddindx).model_number;
          a11(indx) := t(ddindx).short_description;
          a12(indx) := t(ddindx).description;
          a13(indx) := t(ddindx).comments;
          a14(indx) := t(ddindx).record_mode;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure rosetta_table_copy_in_p28(t out nocopy okl_lease_quote_asset_pvt.asset_adjustment_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_2000
    , a13 JTF_VARCHAR2_TABLE_2000
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
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
          t(ddindx).parent_object_code := a2(indx);
          t(ddindx).parent_object_id := a3(indx);
          t(ddindx).adjustment_source_type := a4(indx);
          t(ddindx).adjustment_source_id := a5(indx);
          t(ddindx).basis := a6(indx);
          t(ddindx).value := a7(indx);
          t(ddindx).default_subsidy_amount := a8(indx);
          t(ddindx).processing_type := a9(indx);
          t(ddindx).supplier_id := a10(indx);
          t(ddindx).short_description := a11(indx);
          t(ddindx).description := a12(indx);
          t(ddindx).comments := a13(indx);
          t(ddindx).quote_id := a14(indx);
          t(ddindx).record_mode := a15(indx);
          t(ddindx).adjustment_amount := a16(indx);
          t(ddindx).percent_basis_value := a17(indx);
          t(ddindx).stream_type_id := a18(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p28;
  procedure rosetta_table_copy_out_p28(t okl_lease_quote_asset_pvt.asset_adjustment_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_VARCHAR2_TABLE_2000
    , a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
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
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_2000();
    a13 := JTF_VARCHAR2_TABLE_2000();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_2000();
      a13 := JTF_VARCHAR2_TABLE_2000();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).parent_object_code;
          a3(indx) := t(ddindx).parent_object_id;
          a4(indx) := t(ddindx).adjustment_source_type;
          a5(indx) := t(ddindx).adjustment_source_id;
          a6(indx) := t(ddindx).basis;
          a7(indx) := t(ddindx).value;
          a8(indx) := t(ddindx).default_subsidy_amount;
          a9(indx) := t(ddindx).processing_type;
          a10(indx) := t(ddindx).supplier_id;
          a11(indx) := t(ddindx).short_description;
          a12(indx) := t(ddindx).description;
          a13(indx) := t(ddindx).comments;
          a14(indx) := t(ddindx).quote_id;
          a15(indx) := t(ddindx).record_mode;
          a16(indx) := t(ddindx).adjustment_amount;
          a17(indx) := t(ddindx).percent_basis_value;
          a18(indx) := t(ddindx).stream_type_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p28;

  procedure create_asset(p_api_version  NUMBER
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
    , p3_a18  VARCHAR2
    , p3_a19  NUMBER
    , p3_a20  VARCHAR2
    , p3_a21  NUMBER
    , p3_a22  VARCHAR2
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  VARCHAR2
    , p3_a27  NUMBER
    , p3_a28  NUMBER
    , p3_a29  NUMBER
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_400
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_300
    , p4_a12 JTF_VARCHAR2_TABLE_2000
    , p4_a13 JTF_VARCHAR2_TABLE_2000
    , p4_a14 JTF_VARCHAR2_TABLE_100
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
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_asset_rec okl_lease_quote_asset_pvt.asset_rec_type;
    ddp_component_tbl okl_lease_quote_asset_pvt.asset_component_tbl_type;
    ddp_cf_hdr_rec okl_lease_quote_asset_pvt.cashflow_hdr_rec_type;
    ddp_cf_level_tbl okl_lease_quote_asset_pvt.cashflow_level_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_asset_rec.id := p3_a0;
    ddp_asset_rec.object_version_number := p3_a1;
    ddp_asset_rec.attribute_category := p3_a2;
    ddp_asset_rec.attribute1 := p3_a3;
    ddp_asset_rec.attribute2 := p3_a4;
    ddp_asset_rec.attribute3 := p3_a5;
    ddp_asset_rec.attribute4 := p3_a6;
    ddp_asset_rec.attribute5 := p3_a7;
    ddp_asset_rec.attribute6 := p3_a8;
    ddp_asset_rec.attribute7 := p3_a9;
    ddp_asset_rec.attribute8 := p3_a10;
    ddp_asset_rec.attribute9 := p3_a11;
    ddp_asset_rec.attribute10 := p3_a12;
    ddp_asset_rec.attribute11 := p3_a13;
    ddp_asset_rec.attribute12 := p3_a14;
    ddp_asset_rec.attribute13 := p3_a15;
    ddp_asset_rec.attribute14 := p3_a16;
    ddp_asset_rec.attribute15 := p3_a17;
    ddp_asset_rec.parent_object_code := p3_a18;
    ddp_asset_rec.parent_object_id := p3_a19;
    ddp_asset_rec.asset_number := p3_a20;
    ddp_asset_rec.install_site_id := p3_a21;
    ddp_asset_rec.structured_pricing := p3_a22;
    ddp_asset_rec.rate_template_id := p3_a23;
    ddp_asset_rec.rate_card_id := p3_a24;
    ddp_asset_rec.lease_rate_factor := p3_a25;
    ddp_asset_rec.target_arrears := p3_a26;
    ddp_asset_rec.oec := p3_a27;
    ddp_asset_rec.oec_percentage := p3_a28;
    ddp_asset_rec.end_of_term_value_default := p3_a29;
    ddp_asset_rec.end_of_term_value := p3_a30;
    ddp_asset_rec.orig_asset_id := p3_a31;
    ddp_asset_rec.target_amount := p3_a32;
    ddp_asset_rec.target_frequency := p3_a33;
    ddp_asset_rec.short_description := p3_a34;
    ddp_asset_rec.description := p3_a35;
    ddp_asset_rec.comments := p3_a36;

    okl_lease_quote_asset_pvt_w.rosetta_table_copy_in_p26(ddp_component_tbl, p4_a0
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
      );

    ddp_cf_hdr_rec.type_code := p5_a0;
    ddp_cf_hdr_rec.stream_type_id := p5_a1;
    ddp_cf_hdr_rec.status_code := p5_a2;
    ddp_cf_hdr_rec.arrears_flag := p5_a3;
    ddp_cf_hdr_rec.frequency_code := p5_a4;
    ddp_cf_hdr_rec.dnz_periods := p5_a5;
    ddp_cf_hdr_rec.dnz_periodic_amount := p5_a6;
    ddp_cf_hdr_rec.parent_object_code := p5_a7;
    ddp_cf_hdr_rec.parent_object_id := p5_a8;
    ddp_cf_hdr_rec.quote_type_code := p5_a9;
    ddp_cf_hdr_rec.quote_id := p5_a10;
    ddp_cf_hdr_rec.cashflow_header_id := p5_a11;
    ddp_cf_hdr_rec.cashflow_object_id := p5_a12;
    ddp_cf_hdr_rec.cashflow_header_ovn := p5_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_cf_level_tbl, p6_a0
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




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_asset_pvt.create_asset(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_asset_rec,
      ddp_component_tbl,
      ddp_cf_hdr_rec,
      ddp_cf_level_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure duplicate_asset(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p_source_asset_id  NUMBER
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
    , p4_a18  VARCHAR2
    , p4_a19  NUMBER
    , p4_a20  VARCHAR2
    , p4_a21  NUMBER
    , p4_a22  VARCHAR2
    , p4_a23  NUMBER
    , p4_a24  NUMBER
    , p4_a25  NUMBER
    , p4_a26  VARCHAR2
    , p4_a27  NUMBER
    , p4_a28  NUMBER
    , p4_a29  NUMBER
    , p4_a30  NUMBER
    , p4_a31  NUMBER
    , p4_a32  NUMBER
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_400
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_VARCHAR2_TABLE_2000
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_VARCHAR2_TABLE_100
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
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_asset_rec okl_lease_quote_asset_pvt.asset_rec_type;
    ddp_component_tbl okl_lease_quote_asset_pvt.asset_component_tbl_type;
    ddp_cf_hdr_rec okl_lease_quote_asset_pvt.cashflow_hdr_rec_type;
    ddp_cf_level_tbl okl_lease_quote_asset_pvt.cashflow_level_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_asset_rec.id := p4_a0;
    ddp_asset_rec.object_version_number := p4_a1;
    ddp_asset_rec.attribute_category := p4_a2;
    ddp_asset_rec.attribute1 := p4_a3;
    ddp_asset_rec.attribute2 := p4_a4;
    ddp_asset_rec.attribute3 := p4_a5;
    ddp_asset_rec.attribute4 := p4_a6;
    ddp_asset_rec.attribute5 := p4_a7;
    ddp_asset_rec.attribute6 := p4_a8;
    ddp_asset_rec.attribute7 := p4_a9;
    ddp_asset_rec.attribute8 := p4_a10;
    ddp_asset_rec.attribute9 := p4_a11;
    ddp_asset_rec.attribute10 := p4_a12;
    ddp_asset_rec.attribute11 := p4_a13;
    ddp_asset_rec.attribute12 := p4_a14;
    ddp_asset_rec.attribute13 := p4_a15;
    ddp_asset_rec.attribute14 := p4_a16;
    ddp_asset_rec.attribute15 := p4_a17;
    ddp_asset_rec.parent_object_code := p4_a18;
    ddp_asset_rec.parent_object_id := p4_a19;
    ddp_asset_rec.asset_number := p4_a20;
    ddp_asset_rec.install_site_id := p4_a21;
    ddp_asset_rec.structured_pricing := p4_a22;
    ddp_asset_rec.rate_template_id := p4_a23;
    ddp_asset_rec.rate_card_id := p4_a24;
    ddp_asset_rec.lease_rate_factor := p4_a25;
    ddp_asset_rec.target_arrears := p4_a26;
    ddp_asset_rec.oec := p4_a27;
    ddp_asset_rec.oec_percentage := p4_a28;
    ddp_asset_rec.end_of_term_value_default := p4_a29;
    ddp_asset_rec.end_of_term_value := p4_a30;
    ddp_asset_rec.orig_asset_id := p4_a31;
    ddp_asset_rec.target_amount := p4_a32;
    ddp_asset_rec.target_frequency := p4_a33;
    ddp_asset_rec.short_description := p4_a34;
    ddp_asset_rec.description := p4_a35;
    ddp_asset_rec.comments := p4_a36;

    okl_lease_quote_asset_pvt_w.rosetta_table_copy_in_p26(ddp_component_tbl, p5_a0
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
      );

    ddp_cf_hdr_rec.type_code := p6_a0;
    ddp_cf_hdr_rec.stream_type_id := p6_a1;
    ddp_cf_hdr_rec.status_code := p6_a2;
    ddp_cf_hdr_rec.arrears_flag := p6_a3;
    ddp_cf_hdr_rec.frequency_code := p6_a4;
    ddp_cf_hdr_rec.dnz_periods := p6_a5;
    ddp_cf_hdr_rec.dnz_periodic_amount := p6_a6;
    ddp_cf_hdr_rec.parent_object_code := p6_a7;
    ddp_cf_hdr_rec.parent_object_id := p6_a8;
    ddp_cf_hdr_rec.quote_type_code := p6_a9;
    ddp_cf_hdr_rec.quote_id := p6_a10;
    ddp_cf_hdr_rec.cashflow_header_id := p6_a11;
    ddp_cf_hdr_rec.cashflow_object_id := p6_a12;
    ddp_cf_hdr_rec.cashflow_header_ovn := p6_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_cf_level_tbl, p7_a0
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




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_asset_pvt.duplicate_asset(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      p_source_asset_id,
      ddp_asset_rec,
      ddp_component_tbl,
      ddp_cf_hdr_rec,
      ddp_cf_level_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_asset(p_api_version  NUMBER
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
    , p3_a18  VARCHAR2
    , p3_a19  NUMBER
    , p3_a20  VARCHAR2
    , p3_a21  NUMBER
    , p3_a22  VARCHAR2
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  VARCHAR2
    , p3_a27  NUMBER
    , p3_a28  NUMBER
    , p3_a29  NUMBER
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_400
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_300
    , p4_a12 JTF_VARCHAR2_TABLE_2000
    , p4_a13 JTF_VARCHAR2_TABLE_2000
    , p4_a14 JTF_VARCHAR2_TABLE_100
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
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_asset_rec okl_lease_quote_asset_pvt.asset_rec_type;
    ddp_component_tbl okl_lease_quote_asset_pvt.asset_component_tbl_type;
    ddp_cf_hdr_rec okl_lease_quote_asset_pvt.cashflow_hdr_rec_type;
    ddp_cf_level_tbl okl_lease_quote_asset_pvt.cashflow_level_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_asset_rec.id := p3_a0;
    ddp_asset_rec.object_version_number := p3_a1;
    ddp_asset_rec.attribute_category := p3_a2;
    ddp_asset_rec.attribute1 := p3_a3;
    ddp_asset_rec.attribute2 := p3_a4;
    ddp_asset_rec.attribute3 := p3_a5;
    ddp_asset_rec.attribute4 := p3_a6;
    ddp_asset_rec.attribute5 := p3_a7;
    ddp_asset_rec.attribute6 := p3_a8;
    ddp_asset_rec.attribute7 := p3_a9;
    ddp_asset_rec.attribute8 := p3_a10;
    ddp_asset_rec.attribute9 := p3_a11;
    ddp_asset_rec.attribute10 := p3_a12;
    ddp_asset_rec.attribute11 := p3_a13;
    ddp_asset_rec.attribute12 := p3_a14;
    ddp_asset_rec.attribute13 := p3_a15;
    ddp_asset_rec.attribute14 := p3_a16;
    ddp_asset_rec.attribute15 := p3_a17;
    ddp_asset_rec.parent_object_code := p3_a18;
    ddp_asset_rec.parent_object_id := p3_a19;
    ddp_asset_rec.asset_number := p3_a20;
    ddp_asset_rec.install_site_id := p3_a21;
    ddp_asset_rec.structured_pricing := p3_a22;
    ddp_asset_rec.rate_template_id := p3_a23;
    ddp_asset_rec.rate_card_id := p3_a24;
    ddp_asset_rec.lease_rate_factor := p3_a25;
    ddp_asset_rec.target_arrears := p3_a26;
    ddp_asset_rec.oec := p3_a27;
    ddp_asset_rec.oec_percentage := p3_a28;
    ddp_asset_rec.end_of_term_value_default := p3_a29;
    ddp_asset_rec.end_of_term_value := p3_a30;
    ddp_asset_rec.orig_asset_id := p3_a31;
    ddp_asset_rec.target_amount := p3_a32;
    ddp_asset_rec.target_frequency := p3_a33;
    ddp_asset_rec.short_description := p3_a34;
    ddp_asset_rec.description := p3_a35;
    ddp_asset_rec.comments := p3_a36;

    okl_lease_quote_asset_pvt_w.rosetta_table_copy_in_p26(ddp_component_tbl, p4_a0
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
      );

    ddp_cf_hdr_rec.type_code := p5_a0;
    ddp_cf_hdr_rec.stream_type_id := p5_a1;
    ddp_cf_hdr_rec.status_code := p5_a2;
    ddp_cf_hdr_rec.arrears_flag := p5_a3;
    ddp_cf_hdr_rec.frequency_code := p5_a4;
    ddp_cf_hdr_rec.dnz_periods := p5_a5;
    ddp_cf_hdr_rec.dnz_periodic_amount := p5_a6;
    ddp_cf_hdr_rec.parent_object_code := p5_a7;
    ddp_cf_hdr_rec.parent_object_id := p5_a8;
    ddp_cf_hdr_rec.quote_type_code := p5_a9;
    ddp_cf_hdr_rec.quote_id := p5_a10;
    ddp_cf_hdr_rec.cashflow_header_id := p5_a11;
    ddp_cf_hdr_rec.cashflow_object_id := p5_a12;
    ddp_cf_hdr_rec.cashflow_header_ovn := p5_a13;

    okl_lease_quote_cashflow_pvt_w.rosetta_table_copy_in_p21(ddp_cf_level_tbl, p6_a0
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




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_asset_pvt.update_asset(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_asset_rec,
      ddp_component_tbl,
      ddp_cf_hdr_rec,
      ddp_cf_level_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure create_adjustment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_VARCHAR2_TABLE_100
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_100
    , p3_a10 JTF_NUMBER_TABLE
    , p3_a11 JTF_VARCHAR2_TABLE_300
    , p3_a12 JTF_VARCHAR2_TABLE_2000
    , p3_a13 JTF_VARCHAR2_TABLE_2000
    , p3_a14 JTF_NUMBER_TABLE
    , p3_a15 JTF_VARCHAR2_TABLE_100
    , p3_a16 JTF_NUMBER_TABLE
    , p3_a17 JTF_NUMBER_TABLE
    , p3_a18 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_asset_adj_tbl okl_lease_quote_asset_pvt.asset_adjustment_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    okl_lease_quote_asset_pvt_w.rosetta_table_copy_in_p28(ddp_asset_adj_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_asset_pvt.create_adjustment(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_asset_adj_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure update_adjustment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_VARCHAR2_TABLE_100
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_100
    , p3_a10 JTF_NUMBER_TABLE
    , p3_a11 JTF_VARCHAR2_TABLE_300
    , p3_a12 JTF_VARCHAR2_TABLE_2000
    , p3_a13 JTF_VARCHAR2_TABLE_2000
    , p3_a14 JTF_NUMBER_TABLE
    , p3_a15 JTF_VARCHAR2_TABLE_100
    , p3_a16 JTF_NUMBER_TABLE
    , p3_a17 JTF_NUMBER_TABLE
    , p3_a18 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_asset_adj_tbl okl_lease_quote_asset_pvt.asset_adjustment_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    okl_lease_quote_asset_pvt_w.rosetta_table_copy_in_p28(ddp_asset_adj_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_asset_pvt.update_adjustment(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_asset_adj_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_assets_with_adjustments(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_VARCHAR2_TABLE_500
    , p3_a4 JTF_VARCHAR2_TABLE_500
    , p3_a5 JTF_VARCHAR2_TABLE_500
    , p3_a6 JTF_VARCHAR2_TABLE_500
    , p3_a7 JTF_VARCHAR2_TABLE_500
    , p3_a8 JTF_VARCHAR2_TABLE_500
    , p3_a9 JTF_VARCHAR2_TABLE_500
    , p3_a10 JTF_VARCHAR2_TABLE_500
    , p3_a11 JTF_VARCHAR2_TABLE_500
    , p3_a12 JTF_VARCHAR2_TABLE_500
    , p3_a13 JTF_VARCHAR2_TABLE_500
    , p3_a14 JTF_VARCHAR2_TABLE_500
    , p3_a15 JTF_VARCHAR2_TABLE_500
    , p3_a16 JTF_VARCHAR2_TABLE_500
    , p3_a17 JTF_VARCHAR2_TABLE_500
    , p3_a18 JTF_VARCHAR2_TABLE_100
    , p3_a19 JTF_NUMBER_TABLE
    , p3_a20 JTF_VARCHAR2_TABLE_100
    , p3_a21 JTF_NUMBER_TABLE
    , p3_a22 JTF_VARCHAR2_TABLE_100
    , p3_a23 JTF_NUMBER_TABLE
    , p3_a24 JTF_NUMBER_TABLE
    , p3_a25 JTF_NUMBER_TABLE
    , p3_a26 JTF_VARCHAR2_TABLE_100
    , p3_a27 JTF_NUMBER_TABLE
    , p3_a28 JTF_NUMBER_TABLE
    , p3_a29 JTF_NUMBER_TABLE
    , p3_a30 JTF_NUMBER_TABLE
    , p3_a31 JTF_NUMBER_TABLE
    , p3_a32 JTF_NUMBER_TABLE
    , p3_a33 JTF_VARCHAR2_TABLE_100
    , p3_a34 JTF_VARCHAR2_TABLE_300
    , p3_a35 JTF_VARCHAR2_TABLE_2000
    , p3_a36 JTF_VARCHAR2_TABLE_2000
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_400
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_300
    , p4_a12 JTF_VARCHAR2_TABLE_2000
    , p4_a13 JTF_VARCHAR2_TABLE_2000
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_300
    , p5_a12 JTF_VARCHAR2_TABLE_2000
    , p5_a13 JTF_VARCHAR2_TABLE_2000
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_asset_tbl okl_lease_quote_asset_pvt.asset_tbl_type;
    ddp_component_tbl okl_lease_quote_asset_pvt.asset_component_tbl_type;
    ddp_asset_adj_tbl okl_lease_quote_asset_pvt.asset_adjustment_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    okl_ass_pvt_w.rosetta_table_copy_in_p23(ddp_asset_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      , p3_a32
      , p3_a33
      , p3_a34
      , p3_a35
      , p3_a36
      );

    okl_lease_quote_asset_pvt_w.rosetta_table_copy_in_p26(ddp_component_tbl, p4_a0
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
      );

    okl_lease_quote_asset_pvt_w.rosetta_table_copy_in_p28(ddp_asset_adj_tbl, p5_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_asset_pvt.create_assets_with_adjustments(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_asset_tbl,
      ddp_component_tbl,
      ddp_asset_adj_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure process_link_assets(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_VARCHAR2_TABLE_100
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_100
    , p3_a10 JTF_NUMBER_TABLE
    , p3_a11 JTF_VARCHAR2_TABLE_300
    , p3_a12 JTF_VARCHAR2_TABLE_2000
    , p3_a13 JTF_VARCHAR2_TABLE_2000
    , p3_a14 JTF_NUMBER_TABLE
    , p3_a15 JTF_VARCHAR2_TABLE_100
    , p3_a16 JTF_NUMBER_TABLE
    , p3_a17 JTF_NUMBER_TABLE
    , p3_a18 JTF_NUMBER_TABLE
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_NUMBER_TABLE
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a12 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a14 out nocopy JTF_NUMBER_TABLE
    , p4_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a16 out nocopy JTF_NUMBER_TABLE
    , p4_a17 out nocopy JTF_NUMBER_TABLE
    , p4_a18 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_asset_adj_tbl okl_lease_quote_asset_pvt.asset_adjustment_tbl_type;
    ddx_asset_adj_tbl okl_lease_quote_asset_pvt.asset_adjustment_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    okl_lease_quote_asset_pvt_w.rosetta_table_copy_in_p28(ddp_asset_adj_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      );





    -- here's the delegated call to the old PL/SQL routine
    okl_lease_quote_asset_pvt.process_link_assets(p_api_version,
      p_init_msg_list,
      p_transaction_control,
      ddp_asset_adj_tbl,
      ddx_asset_adj_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    okl_lease_quote_asset_pvt_w.rosetta_table_copy_out_p28(ddx_asset_adj_tbl, p4_a0
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
      );



  end;

end okl_lease_quote_asset_pvt_w;

/
