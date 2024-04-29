--------------------------------------------------------
--  DDL for Package Body OKL_DEAL_ASSET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEAL_ASSET_PVT_W" as
  /* $Header: OKLEDASB.pls 120.1.12010000.2 2010/04/30 04:59:38 rpillay ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy okl_deal_asset_pvt.addon_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_400
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cleb_addon_id := a0(indx);
          t(ddindx).dnz_chr_id := a1(indx);
          t(ddindx).price_unit := a2(indx);
          t(ddindx).inventory_item_id := a3(indx);
          t(ddindx).inventory_org_id := a4(indx);
          t(ddindx).jtot_object1_code := a5(indx);
          t(ddindx).number_of_items := a6(indx);
          t(ddindx).manufacturer_name := a7(indx);
          t(ddindx).model_number := a8(indx);
          t(ddindx).year_of_manufacture := a9(indx);
          t(ddindx).vendor_name := a10(indx);
          t(ddindx).party_role_id := a11(indx);
          t(ddindx).vendor_id := a12(indx);
          t(ddindx).object1_id2 := a13(indx);
          t(ddindx).rle_code := a14(indx);
          t(ddindx).comments := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_deal_asset_pvt.addon_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_400
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
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
    a7 := JTF_VARCHAR2_TABLE_400();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_400();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_2000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cleb_addon_id;
          a1(indx) := t(ddindx).dnz_chr_id;
          a2(indx) := t(ddindx).price_unit;
          a3(indx) := t(ddindx).inventory_item_id;
          a4(indx) := t(ddindx).inventory_org_id;
          a5(indx) := t(ddindx).jtot_object1_code;
          a6(indx) := t(ddindx).number_of_items;
          a7(indx) := t(ddindx).manufacturer_name;
          a8(indx) := t(ddindx).model_number;
          a9(indx) := t(ddindx).year_of_manufacture;
          a10(indx) := t(ddindx).vendor_name;
          a11(indx) := t(ddindx).party_role_id;
          a12(indx) := t(ddindx).vendor_id;
          a13(indx) := t(ddindx).object1_id2;
          a14(indx) := t(ddindx).rle_code;
          a15(indx) := t(ddindx).comments;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy okl_deal_asset_pvt.down_payment_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cleb_fin_id := a0(indx);
          t(ddindx).dnz_chr_id := a1(indx);
          t(ddindx).asset_number := a2(indx);
          t(ddindx).asset_cost := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).basis := a5(indx);
          t(ddindx).down_payment := a6(indx);
          t(ddindx).down_payment_receiver_code := a7(indx);
          t(ddindx).capitalize_down_payment_yn := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t okl_deal_asset_pvt.down_payment_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cleb_fin_id;
          a1(indx) := t(ddindx).dnz_chr_id;
          a2(indx) := t(ddindx).asset_number;
          a3(indx) := t(ddindx).asset_cost;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).basis;
          a6(indx) := t(ddindx).down_payment;
          a7(indx) := t(ddindx).down_payment_receiver_code;
          a8(indx) := t(ddindx).capitalize_down_payment_yn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy okl_deal_asset_pvt.tradein_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cleb_fin_id := a0(indx);
          t(ddindx).dnz_chr_id := a1(indx);
          t(ddindx).asset_number := a2(indx);
          t(ddindx).asset_cost := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).tradein_amount := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t okl_deal_asset_pvt.tradein_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_2000();
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
          a0(indx) := t(ddindx).cleb_fin_id;
          a1(indx) := t(ddindx).dnz_chr_id;
          a2(indx) := t(ddindx).asset_number;
          a3(indx) := t(ddindx).asset_cost;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).tradein_amount;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure process_line_billing_setup(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  NUMBER
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
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
  )

  as
    ddp_rgpv_rec okl_deal_terms_pvt.billing_setup_rec_type;
    ddx_rgpv_rec okl_deal_terms_pvt.billing_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.chr_id := p5_a0;
    ddp_rgpv_rec.cle_id := p5_a1;
    ddp_rgpv_rec.asset_number := p5_a2;
    ddp_rgpv_rec.item_description := p5_a3;
    ddp_rgpv_rec.rgp_id := p5_a4;
    ddp_rgpv_rec.bill_to_site_use_id := p5_a5;
    ddp_rgpv_rec.bill_to_site_name := p5_a6;
    ddp_rgpv_rec.rgp_labill_lapmth_id := p5_a7;
    ddp_rgpv_rec.rgp_labill_labacc_id := p5_a8;
    ddp_rgpv_rec.rgp_labill_lainvd_id := p5_a9;
    ddp_rgpv_rec.rgp_labill_lainpr_id := p5_a10;
    ddp_rgpv_rec.rul_lapmth_id := p5_a11;
    ddp_rgpv_rec.rul_labacc_id := p5_a12;
    ddp_rgpv_rec.rul_lainvd_id := p5_a13;
    ddp_rgpv_rec.rul_lainpr_id := p5_a14;
    ddp_rgpv_rec.rul_lapmth_object1_id1 := p5_a15;
    ddp_rgpv_rec.rul_lapmth_object1_id2 := p5_a16;
    ddp_rgpv_rec.rul_lapmth_name := p5_a17;
    ddp_rgpv_rec.rul_labacc_object1_id1 := p5_a18;
    ddp_rgpv_rec.rul_labacc_object1_id2 := p5_a19;
    ddp_rgpv_rec.rul_labacc_name := p5_a20;
    ddp_rgpv_rec.rul_labacc_bank_name := p5_a21;
    ddp_rgpv_rec.lainvd_invoice_format_meaning := p5_a22;
    ddp_rgpv_rec.lainvd_rule_information1 := p5_a23;
    ddp_rgpv_rec.lainvd_rule_information3 := p5_a24;
    ddp_rgpv_rec.lainvd_rule_information4 := p5_a25;
    ddp_rgpv_rec.rul_lainvd_object1_id1 := p5_a26;
    ddp_rgpv_rec.rul_lainvd_object1_id2 := p5_a27;
    ddp_rgpv_rec.rul_lainvd_name := p5_a28;
    ddp_rgpv_rec.lainpr_rule_information1 := p5_a29;
    ddp_rgpv_rec.lainpr_rule_information2 := p5_a30;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_asset_pvt.process_line_billing_setup(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rgpv_rec.chr_id;
    p6_a1 := ddx_rgpv_rec.cle_id;
    p6_a2 := ddx_rgpv_rec.asset_number;
    p6_a3 := ddx_rgpv_rec.item_description;
    p6_a4 := ddx_rgpv_rec.rgp_id;
    p6_a5 := ddx_rgpv_rec.bill_to_site_use_id;
    p6_a6 := ddx_rgpv_rec.bill_to_site_name;
    p6_a7 := ddx_rgpv_rec.rgp_labill_lapmth_id;
    p6_a8 := ddx_rgpv_rec.rgp_labill_labacc_id;
    p6_a9 := ddx_rgpv_rec.rgp_labill_lainvd_id;
    p6_a10 := ddx_rgpv_rec.rgp_labill_lainpr_id;
    p6_a11 := ddx_rgpv_rec.rul_lapmth_id;
    p6_a12 := ddx_rgpv_rec.rul_labacc_id;
    p6_a13 := ddx_rgpv_rec.rul_lainvd_id;
    p6_a14 := ddx_rgpv_rec.rul_lainpr_id;
    p6_a15 := ddx_rgpv_rec.rul_lapmth_object1_id1;
    p6_a16 := ddx_rgpv_rec.rul_lapmth_object1_id2;
    p6_a17 := ddx_rgpv_rec.rul_lapmth_name;
    p6_a18 := ddx_rgpv_rec.rul_labacc_object1_id1;
    p6_a19 := ddx_rgpv_rec.rul_labacc_object1_id2;
    p6_a20 := ddx_rgpv_rec.rul_labacc_name;
    p6_a21 := ddx_rgpv_rec.rul_labacc_bank_name;
    p6_a22 := ddx_rgpv_rec.lainvd_invoice_format_meaning;
    p6_a23 := ddx_rgpv_rec.lainvd_rule_information1;
    p6_a24 := ddx_rgpv_rec.lainvd_rule_information3;
    p6_a25 := ddx_rgpv_rec.lainvd_rule_information4;
    p6_a26 := ddx_rgpv_rec.rul_lainvd_object1_id1;
    p6_a27 := ddx_rgpv_rec.rul_lainvd_object1_id2;
    p6_a28 := ddx_rgpv_rec.rul_lainvd_name;
    p6_a29 := ddx_rgpv_rec.lainpr_rule_information1;
    p6_a30 := ddx_rgpv_rec.lainpr_rule_information2;
  end;

  procedure load_line_billing_setup(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_dnz_chr_id  NUMBER
    , p_cle_id  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  NUMBER
    , p7_a14 out nocopy  NUMBER
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
  )

  as
    ddx_billing_setup_rec okl_deal_terms_pvt.billing_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_deal_asset_pvt.load_line_billing_setup(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_dnz_chr_id,
      p_cle_id,
      ddx_billing_setup_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_billing_setup_rec.chr_id;
    p7_a1 := ddx_billing_setup_rec.cle_id;
    p7_a2 := ddx_billing_setup_rec.asset_number;
    p7_a3 := ddx_billing_setup_rec.item_description;
    p7_a4 := ddx_billing_setup_rec.rgp_id;
    p7_a5 := ddx_billing_setup_rec.bill_to_site_use_id;
    p7_a6 := ddx_billing_setup_rec.bill_to_site_name;
    p7_a7 := ddx_billing_setup_rec.rgp_labill_lapmth_id;
    p7_a8 := ddx_billing_setup_rec.rgp_labill_labacc_id;
    p7_a9 := ddx_billing_setup_rec.rgp_labill_lainvd_id;
    p7_a10 := ddx_billing_setup_rec.rgp_labill_lainpr_id;
    p7_a11 := ddx_billing_setup_rec.rul_lapmth_id;
    p7_a12 := ddx_billing_setup_rec.rul_labacc_id;
    p7_a13 := ddx_billing_setup_rec.rul_lainvd_id;
    p7_a14 := ddx_billing_setup_rec.rul_lainpr_id;
    p7_a15 := ddx_billing_setup_rec.rul_lapmth_object1_id1;
    p7_a16 := ddx_billing_setup_rec.rul_lapmth_object1_id2;
    p7_a17 := ddx_billing_setup_rec.rul_lapmth_name;
    p7_a18 := ddx_billing_setup_rec.rul_labacc_object1_id1;
    p7_a19 := ddx_billing_setup_rec.rul_labacc_object1_id2;
    p7_a20 := ddx_billing_setup_rec.rul_labacc_name;
    p7_a21 := ddx_billing_setup_rec.rul_labacc_bank_name;
    p7_a22 := ddx_billing_setup_rec.lainvd_invoice_format_meaning;
    p7_a23 := ddx_billing_setup_rec.lainvd_rule_information1;
    p7_a24 := ddx_billing_setup_rec.lainvd_rule_information3;
    p7_a25 := ddx_billing_setup_rec.lainvd_rule_information4;
    p7_a26 := ddx_billing_setup_rec.rul_lainvd_object1_id1;
    p7_a27 := ddx_billing_setup_rec.rul_lainvd_object1_id2;
    p7_a28 := ddx_billing_setup_rec.rul_lainvd_name;
    p7_a29 := ddx_billing_setup_rec.lainpr_rule_information1;
    p7_a30 := ddx_billing_setup_rec.lainpr_rule_information2;
  end;

  procedure create_assetaddon_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
  )

  as
    ddp_addon_rec okl_deal_asset_pvt.addon_rec_type;
    ddx_addon_rec okl_deal_asset_pvt.addon_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_addon_rec.cleb_addon_id := p5_a0;
    ddp_addon_rec.dnz_chr_id := p5_a1;
    ddp_addon_rec.price_unit := p5_a2;
    ddp_addon_rec.inventory_item_id := p5_a3;
    ddp_addon_rec.inventory_org_id := p5_a4;
    ddp_addon_rec.jtot_object1_code := p5_a5;
    ddp_addon_rec.number_of_items := p5_a6;
    ddp_addon_rec.manufacturer_name := p5_a7;
    ddp_addon_rec.model_number := p5_a8;
    ddp_addon_rec.year_of_manufacture := p5_a9;
    ddp_addon_rec.vendor_name := p5_a10;
    ddp_addon_rec.party_role_id := p5_a11;
    ddp_addon_rec.vendor_id := p5_a12;
    ddp_addon_rec.object1_id2 := p5_a13;
    ddp_addon_rec.rle_code := p5_a14;
    ddp_addon_rec.comments := p5_a15;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_asset_pvt.create_assetaddon_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_addon_rec,
      ddx_addon_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_addon_rec.cleb_addon_id;
    p6_a1 := ddx_addon_rec.dnz_chr_id;
    p6_a2 := ddx_addon_rec.price_unit;
    p6_a3 := ddx_addon_rec.inventory_item_id;
    p6_a4 := ddx_addon_rec.inventory_org_id;
    p6_a5 := ddx_addon_rec.jtot_object1_code;
    p6_a6 := ddx_addon_rec.number_of_items;
    p6_a7 := ddx_addon_rec.manufacturer_name;
    p6_a8 := ddx_addon_rec.model_number;
    p6_a9 := ddx_addon_rec.year_of_manufacture;
    p6_a10 := ddx_addon_rec.vendor_name;
    p6_a11 := ddx_addon_rec.party_role_id;
    p6_a12 := ddx_addon_rec.vendor_id;
    p6_a13 := ddx_addon_rec.object1_id2;
    p6_a14 := ddx_addon_rec.rle_code;
    p6_a15 := ddx_addon_rec.comments;
  end;

  procedure create_assetaddon_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_400
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_300
    , p5_a10 JTF_VARCHAR2_TABLE_300
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_2000
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_addon_tbl okl_deal_asset_pvt.addon_tbl_type;
    ddx_addon_tbl okl_deal_asset_pvt.addon_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_deal_asset_pvt_w.rosetta_table_copy_in_p2(ddp_addon_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_asset_pvt.create_assetaddon_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_addon_tbl,
      ddx_addon_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_deal_asset_pvt_w.rosetta_table_copy_out_p2(ddx_addon_tbl, p6_a0
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
      );
  end;

  procedure update_assetaddon_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  NUMBER
    , p5_a4  NUMBER
    , p5_a5  VARCHAR2
    , p5_a6  NUMBER
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
  )

  as
    ddp_addon_rec okl_deal_asset_pvt.addon_rec_type;
    ddx_addon_rec okl_deal_asset_pvt.addon_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_addon_rec.cleb_addon_id := p5_a0;
    ddp_addon_rec.dnz_chr_id := p5_a1;
    ddp_addon_rec.price_unit := p5_a2;
    ddp_addon_rec.inventory_item_id := p5_a3;
    ddp_addon_rec.inventory_org_id := p5_a4;
    ddp_addon_rec.jtot_object1_code := p5_a5;
    ddp_addon_rec.number_of_items := p5_a6;
    ddp_addon_rec.manufacturer_name := p5_a7;
    ddp_addon_rec.model_number := p5_a8;
    ddp_addon_rec.year_of_manufacture := p5_a9;
    ddp_addon_rec.vendor_name := p5_a10;
    ddp_addon_rec.party_role_id := p5_a11;
    ddp_addon_rec.vendor_id := p5_a12;
    ddp_addon_rec.object1_id2 := p5_a13;
    ddp_addon_rec.rle_code := p5_a14;
    ddp_addon_rec.comments := p5_a15;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_asset_pvt.update_assetaddon_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_addon_rec,
      ddx_addon_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_addon_rec.cleb_addon_id;
    p6_a1 := ddx_addon_rec.dnz_chr_id;
    p6_a2 := ddx_addon_rec.price_unit;
    p6_a3 := ddx_addon_rec.inventory_item_id;
    p6_a4 := ddx_addon_rec.inventory_org_id;
    p6_a5 := ddx_addon_rec.jtot_object1_code;
    p6_a6 := ddx_addon_rec.number_of_items;
    p6_a7 := ddx_addon_rec.manufacturer_name;
    p6_a8 := ddx_addon_rec.model_number;
    p6_a9 := ddx_addon_rec.year_of_manufacture;
    p6_a10 := ddx_addon_rec.vendor_name;
    p6_a11 := ddx_addon_rec.party_role_id;
    p6_a12 := ddx_addon_rec.vendor_id;
    p6_a13 := ddx_addon_rec.object1_id2;
    p6_a14 := ddx_addon_rec.rle_code;
    p6_a15 := ddx_addon_rec.comments;
  end;

  procedure update_assetaddon_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_400
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_300
    , p5_a10 JTF_VARCHAR2_TABLE_300
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_2000
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_addon_tbl okl_deal_asset_pvt.addon_tbl_type;
    ddx_addon_tbl okl_deal_asset_pvt.addon_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_deal_asset_pvt_w.rosetta_table_copy_in_p2(ddp_addon_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_asset_pvt.update_assetaddon_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_addon_tbl,
      ddx_addon_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_deal_asset_pvt_w.rosetta_table_copy_out_p2(ddx_addon_tbl, p6_a0
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
      );
  end;

  procedure create_all_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  VARCHAR2
    , p5_a16  NUMBER
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  DATE
    , p5_a22  DATE
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  NUMBER
    , p5_a32  NUMBER
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
    , p5_a47  VARCHAR2
    , p5_a48  VARCHAR2
    , p5_a49  VARCHAR2
    , p5_a50  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
  )

  as
    ddp_las_rec okl_deal_asset_pvt.las_rec_type;
    ddx_las_rec okl_deal_asset_pvt.las_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_las_rec.deal_type := p5_a0;
    ddp_las_rec.inventory_item_id := p5_a1;
    ddp_las_rec.inventory_org_id := p5_a2;
    ddp_las_rec.inventory_item_name := p5_a3;
    if p5_a4 is null
      then ddp_las_rec.release_asset_flag := null;
    elsif p5_a4 = 0
      then ddp_las_rec.release_asset_flag := false;
    else ddp_las_rec.release_asset_flag := true;
    end if;
    ddp_las_rec.asset_id := p5_a5;
    ddp_las_rec.asset_number := p5_a6;
    ddp_las_rec.description := p5_a7;
    ddp_las_rec.unit_cost := p5_a8;
    ddp_las_rec.units := p5_a9;
    ddp_las_rec.old_units := p5_a10;
    ddp_las_rec.model_number := p5_a11;
    ddp_las_rec.manufacturer_name := p5_a12;
    ddp_las_rec.year_manufactured := p5_a13;
    ddp_las_rec.party_site_use_id := p5_a14;
    ddp_las_rec.party_site_name := p5_a15;
    ddp_las_rec.fa_location_id := p5_a16;
    ddp_las_rec.fa_location_name := p5_a17;
    ddp_las_rec.asset_key_id := p5_a18;
    ddp_las_rec.asset_key_name := p5_a19;
    ddp_las_rec.prescribed_asset_yn := p5_a20;
    ddp_las_rec.date_delivery_expected := p5_a21;
    ddp_las_rec.date_funding_expected := p5_a22;
    ddp_las_rec.residual_percentage := p5_a23;
    ddp_las_rec.residual_value := p5_a24;
    ddp_las_rec.residual_code := p5_a25;
    ddp_las_rec.guranteed_amount := p5_a26;
    ddp_las_rec.rvi_premium := p5_a27;
    ddp_las_rec.currency_code := p5_a28;
    ddp_las_rec.dnz_chr_id := p5_a29;
    ddp_las_rec.clev_fin_id := p5_a30;
    ddp_las_rec.clev_model_id := p5_a31;
    ddp_las_rec.clev_fa_id := p5_a32;
    ddp_las_rec.clev_ib_id := p5_a33;
    ddp_las_rec.tal_id := p5_a34;
    ddp_las_rec.attribute_category := p5_a35;
    ddp_las_rec.attribute1 := p5_a36;
    ddp_las_rec.attribute2 := p5_a37;
    ddp_las_rec.attribute3 := p5_a38;
    ddp_las_rec.attribute4 := p5_a39;
    ddp_las_rec.attribute5 := p5_a40;
    ddp_las_rec.attribute6 := p5_a41;
    ddp_las_rec.attribute7 := p5_a42;
    ddp_las_rec.attribute8 := p5_a43;
    ddp_las_rec.attribute9 := p5_a44;
    ddp_las_rec.attribute10 := p5_a45;
    ddp_las_rec.attribute11 := p5_a46;
    ddp_las_rec.attribute12 := p5_a47;
    ddp_las_rec.attribute13 := p5_a48;
    ddp_las_rec.attribute14 := p5_a49;
    ddp_las_rec.attribute15 := p5_a50;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_asset_pvt.create_all_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_las_rec,
      ddx_las_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_las_rec.deal_type;
    p6_a1 := ddx_las_rec.inventory_item_id;
    p6_a2 := ddx_las_rec.inventory_org_id;
    p6_a3 := ddx_las_rec.inventory_item_name;
    if ddx_las_rec.release_asset_flag is null
      then p6_a4 := null;
    elsif ddx_las_rec.release_asset_flag
      then p6_a4 := 1;
    else p6_a4 := 0;
    end if;
    p6_a5 := ddx_las_rec.asset_id;
    p6_a6 := ddx_las_rec.asset_number;
    p6_a7 := ddx_las_rec.description;
    p6_a8 := ddx_las_rec.unit_cost;
    p6_a9 := ddx_las_rec.units;
    p6_a10 := ddx_las_rec.old_units;
    p6_a11 := ddx_las_rec.model_number;
    p6_a12 := ddx_las_rec.manufacturer_name;
    p6_a13 := ddx_las_rec.year_manufactured;
    p6_a14 := ddx_las_rec.party_site_use_id;
    p6_a15 := ddx_las_rec.party_site_name;
    p6_a16 := ddx_las_rec.fa_location_id;
    p6_a17 := ddx_las_rec.fa_location_name;
    p6_a18 := ddx_las_rec.asset_key_id;
    p6_a19 := ddx_las_rec.asset_key_name;
    p6_a20 := ddx_las_rec.prescribed_asset_yn;
    p6_a21 := ddx_las_rec.date_delivery_expected;
    p6_a22 := ddx_las_rec.date_funding_expected;
    p6_a23 := ddx_las_rec.residual_percentage;
    p6_a24 := ddx_las_rec.residual_value;
    p6_a25 := ddx_las_rec.residual_code;
    p6_a26 := ddx_las_rec.guranteed_amount;
    p6_a27 := ddx_las_rec.rvi_premium;
    p6_a28 := ddx_las_rec.currency_code;
    p6_a29 := ddx_las_rec.dnz_chr_id;
    p6_a30 := ddx_las_rec.clev_fin_id;
    p6_a31 := ddx_las_rec.clev_model_id;
    p6_a32 := ddx_las_rec.clev_fa_id;
    p6_a33 := ddx_las_rec.clev_ib_id;
    p6_a34 := ddx_las_rec.tal_id;
    p6_a35 := ddx_las_rec.attribute_category;
    p6_a36 := ddx_las_rec.attribute1;
    p6_a37 := ddx_las_rec.attribute2;
    p6_a38 := ddx_las_rec.attribute3;
    p6_a39 := ddx_las_rec.attribute4;
    p6_a40 := ddx_las_rec.attribute5;
    p6_a41 := ddx_las_rec.attribute6;
    p6_a42 := ddx_las_rec.attribute7;
    p6_a43 := ddx_las_rec.attribute8;
    p6_a44 := ddx_las_rec.attribute9;
    p6_a45 := ddx_las_rec.attribute10;
    p6_a46 := ddx_las_rec.attribute11;
    p6_a47 := ddx_las_rec.attribute12;
    p6_a48 := ddx_las_rec.attribute13;
    p6_a49 := ddx_las_rec.attribute14;
    p6_a50 := ddx_las_rec.attribute15;
  end;

  procedure update_all_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  VARCHAR2
    , p5_a16  NUMBER
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  DATE
    , p5_a22  DATE
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  NUMBER
    , p5_a32  NUMBER
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
    , p5_a47  VARCHAR2
    , p5_a48  VARCHAR2
    , p5_a49  VARCHAR2
    , p5_a50  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
  )

  as
    ddp_las_rec okl_deal_asset_pvt.las_rec_type;
    ddx_las_rec okl_deal_asset_pvt.las_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_las_rec.deal_type := p5_a0;
    ddp_las_rec.inventory_item_id := p5_a1;
    ddp_las_rec.inventory_org_id := p5_a2;
    ddp_las_rec.inventory_item_name := p5_a3;
    if p5_a4 is null
      then ddp_las_rec.release_asset_flag := null;
    elsif p5_a4 = 0
      then ddp_las_rec.release_asset_flag := false;
    else ddp_las_rec.release_asset_flag := true;
    end if;
    ddp_las_rec.asset_id := p5_a5;
    ddp_las_rec.asset_number := p5_a6;
    ddp_las_rec.description := p5_a7;
    ddp_las_rec.unit_cost := p5_a8;
    ddp_las_rec.units := p5_a9;
    ddp_las_rec.old_units := p5_a10;
    ddp_las_rec.model_number := p5_a11;
    ddp_las_rec.manufacturer_name := p5_a12;
    ddp_las_rec.year_manufactured := p5_a13;
    ddp_las_rec.party_site_use_id := p5_a14;
    ddp_las_rec.party_site_name := p5_a15;
    ddp_las_rec.fa_location_id := p5_a16;
    ddp_las_rec.fa_location_name := p5_a17;
    ddp_las_rec.asset_key_id := p5_a18;
    ddp_las_rec.asset_key_name := p5_a19;
    ddp_las_rec.prescribed_asset_yn := p5_a20;
    ddp_las_rec.date_delivery_expected := p5_a21;
    ddp_las_rec.date_funding_expected := p5_a22;
    ddp_las_rec.residual_percentage := p5_a23;
    ddp_las_rec.residual_value := p5_a24;
    ddp_las_rec.residual_code := p5_a25;
    ddp_las_rec.guranteed_amount := p5_a26;
    ddp_las_rec.rvi_premium := p5_a27;
    ddp_las_rec.currency_code := p5_a28;
    ddp_las_rec.dnz_chr_id := p5_a29;
    ddp_las_rec.clev_fin_id := p5_a30;
    ddp_las_rec.clev_model_id := p5_a31;
    ddp_las_rec.clev_fa_id := p5_a32;
    ddp_las_rec.clev_ib_id := p5_a33;
    ddp_las_rec.tal_id := p5_a34;
    ddp_las_rec.attribute_category := p5_a35;
    ddp_las_rec.attribute1 := p5_a36;
    ddp_las_rec.attribute2 := p5_a37;
    ddp_las_rec.attribute3 := p5_a38;
    ddp_las_rec.attribute4 := p5_a39;
    ddp_las_rec.attribute5 := p5_a40;
    ddp_las_rec.attribute6 := p5_a41;
    ddp_las_rec.attribute7 := p5_a42;
    ddp_las_rec.attribute8 := p5_a43;
    ddp_las_rec.attribute9 := p5_a44;
    ddp_las_rec.attribute10 := p5_a45;
    ddp_las_rec.attribute11 := p5_a46;
    ddp_las_rec.attribute12 := p5_a47;
    ddp_las_rec.attribute13 := p5_a48;
    ddp_las_rec.attribute14 := p5_a49;
    ddp_las_rec.attribute15 := p5_a50;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_asset_pvt.update_all_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_las_rec,
      ddx_las_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_las_rec.deal_type;
    p6_a1 := ddx_las_rec.inventory_item_id;
    p6_a2 := ddx_las_rec.inventory_org_id;
    p6_a3 := ddx_las_rec.inventory_item_name;
    if ddx_las_rec.release_asset_flag is null
      then p6_a4 := null;
    elsif ddx_las_rec.release_asset_flag
      then p6_a4 := 1;
    else p6_a4 := 0;
    end if;
    p6_a5 := ddx_las_rec.asset_id;
    p6_a6 := ddx_las_rec.asset_number;
    p6_a7 := ddx_las_rec.description;
    p6_a8 := ddx_las_rec.unit_cost;
    p6_a9 := ddx_las_rec.units;
    p6_a10 := ddx_las_rec.old_units;
    p6_a11 := ddx_las_rec.model_number;
    p6_a12 := ddx_las_rec.manufacturer_name;
    p6_a13 := ddx_las_rec.year_manufactured;
    p6_a14 := ddx_las_rec.party_site_use_id;
    p6_a15 := ddx_las_rec.party_site_name;
    p6_a16 := ddx_las_rec.fa_location_id;
    p6_a17 := ddx_las_rec.fa_location_name;
    p6_a18 := ddx_las_rec.asset_key_id;
    p6_a19 := ddx_las_rec.asset_key_name;
    p6_a20 := ddx_las_rec.prescribed_asset_yn;
    p6_a21 := ddx_las_rec.date_delivery_expected;
    p6_a22 := ddx_las_rec.date_funding_expected;
    p6_a23 := ddx_las_rec.residual_percentage;
    p6_a24 := ddx_las_rec.residual_value;
    p6_a25 := ddx_las_rec.residual_code;
    p6_a26 := ddx_las_rec.guranteed_amount;
    p6_a27 := ddx_las_rec.rvi_premium;
    p6_a28 := ddx_las_rec.currency_code;
    p6_a29 := ddx_las_rec.dnz_chr_id;
    p6_a30 := ddx_las_rec.clev_fin_id;
    p6_a31 := ddx_las_rec.clev_model_id;
    p6_a32 := ddx_las_rec.clev_fa_id;
    p6_a33 := ddx_las_rec.clev_ib_id;
    p6_a34 := ddx_las_rec.tal_id;
    p6_a35 := ddx_las_rec.attribute_category;
    p6_a36 := ddx_las_rec.attribute1;
    p6_a37 := ddx_las_rec.attribute2;
    p6_a38 := ddx_las_rec.attribute3;
    p6_a39 := ddx_las_rec.attribute4;
    p6_a40 := ddx_las_rec.attribute5;
    p6_a41 := ddx_las_rec.attribute6;
    p6_a42 := ddx_las_rec.attribute7;
    p6_a43 := ddx_las_rec.attribute8;
    p6_a44 := ddx_las_rec.attribute9;
    p6_a45 := ddx_las_rec.attribute10;
    p6_a46 := ddx_las_rec.attribute11;
    p6_a47 := ddx_las_rec.attribute12;
    p6_a48 := ddx_las_rec.attribute13;
    p6_a49 := ddx_las_rec.attribute14;
    p6_a50 := ddx_las_rec.attribute15;
  end;

  procedure load_all_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_clev_fin_id  NUMBER
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  NUMBER
    , p7_a14 out nocopy  NUMBER
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  NUMBER
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  DATE
    , p7_a22 out nocopy  DATE
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  NUMBER
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  NUMBER
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  NUMBER
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  NUMBER
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  VARCHAR2
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
  )

  as
    ddx_las_rec okl_deal_asset_pvt.las_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_deal_asset_pvt.load_all_line(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_clev_fin_id,
      ddx_las_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_las_rec.deal_type;
    p7_a1 := ddx_las_rec.inventory_item_id;
    p7_a2 := ddx_las_rec.inventory_org_id;
    p7_a3 := ddx_las_rec.inventory_item_name;
    if ddx_las_rec.release_asset_flag is null
      then p7_a4 := null;
    elsif ddx_las_rec.release_asset_flag
      then p7_a4 := 1;
    else p7_a4 := 0;
    end if;
    p7_a5 := ddx_las_rec.asset_id;
    p7_a6 := ddx_las_rec.asset_number;
    p7_a7 := ddx_las_rec.description;
    p7_a8 := ddx_las_rec.unit_cost;
    p7_a9 := ddx_las_rec.units;
    p7_a10 := ddx_las_rec.old_units;
    p7_a11 := ddx_las_rec.model_number;
    p7_a12 := ddx_las_rec.manufacturer_name;
    p7_a13 := ddx_las_rec.year_manufactured;
    p7_a14 := ddx_las_rec.party_site_use_id;
    p7_a15 := ddx_las_rec.party_site_name;
    p7_a16 := ddx_las_rec.fa_location_id;
    p7_a17 := ddx_las_rec.fa_location_name;
    p7_a18 := ddx_las_rec.asset_key_id;
    p7_a19 := ddx_las_rec.asset_key_name;
    p7_a20 := ddx_las_rec.prescribed_asset_yn;
    p7_a21 := ddx_las_rec.date_delivery_expected;
    p7_a22 := ddx_las_rec.date_funding_expected;
    p7_a23 := ddx_las_rec.residual_percentage;
    p7_a24 := ddx_las_rec.residual_value;
    p7_a25 := ddx_las_rec.residual_code;
    p7_a26 := ddx_las_rec.guranteed_amount;
    p7_a27 := ddx_las_rec.rvi_premium;
    p7_a28 := ddx_las_rec.currency_code;
    p7_a29 := ddx_las_rec.dnz_chr_id;
    p7_a30 := ddx_las_rec.clev_fin_id;
    p7_a31 := ddx_las_rec.clev_model_id;
    p7_a32 := ddx_las_rec.clev_fa_id;
    p7_a33 := ddx_las_rec.clev_ib_id;
    p7_a34 := ddx_las_rec.tal_id;
    p7_a35 := ddx_las_rec.attribute_category;
    p7_a36 := ddx_las_rec.attribute1;
    p7_a37 := ddx_las_rec.attribute2;
    p7_a38 := ddx_las_rec.attribute3;
    p7_a39 := ddx_las_rec.attribute4;
    p7_a40 := ddx_las_rec.attribute5;
    p7_a41 := ddx_las_rec.attribute6;
    p7_a42 := ddx_las_rec.attribute7;
    p7_a43 := ddx_las_rec.attribute8;
    p7_a44 := ddx_las_rec.attribute9;
    p7_a45 := ddx_las_rec.attribute10;
    p7_a46 := ddx_las_rec.attribute11;
    p7_a47 := ddx_las_rec.attribute12;
    p7_a48 := ddx_las_rec.attribute13;
    p7_a49 := ddx_las_rec.attribute14;
    p7_a50 := ddx_las_rec.attribute15;
  end;

  procedure allocate_amount_tradein(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_tradein_amount  NUMBER
    , p_mode  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a5 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_tradein_tbl okl_deal_asset_pvt.tradein_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    okl_deal_asset_pvt.allocate_amount_tradein(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_tradein_amount,
      p_mode,
      ddx_tradein_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okl_deal_asset_pvt_w.rosetta_table_copy_out_p6(ddx_tradein_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      );
  end;

  procedure allocate_amount_down_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_down_payment  NUMBER
    , p_basis  VARCHAR2
    , p_mode  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_down_payment_tbl okl_deal_asset_pvt.down_payment_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    okl_deal_asset_pvt.allocate_amount_down_payment(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_down_payment,
      p_basis,
      p_mode,
      ddx_down_payment_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    okl_deal_asset_pvt_w.rosetta_table_copy_out_p4(ddx_down_payment_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      );
  end;

end okl_deal_asset_pvt_w;

/
