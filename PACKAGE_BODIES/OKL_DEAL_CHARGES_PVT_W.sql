--------------------------------------------------------
--  DDL for Package Body OKL_DEAL_CHARGES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEAL_CHARGES_PVT_W" as
  /* $Header: OKLEKACB.pls 120.0 2007/04/20 06:27:16 udhenuko noship $ */
  procedure rosetta_table_copy_in_p13(t out nocopy okl_deal_charges_pvt.fee_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_400
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_500
    , a21 JTF_VARCHAR2_TABLE_500
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_VARCHAR2_TABLE_500
    , a28 JTF_VARCHAR2_TABLE_500
    , a29 JTF_VARCHAR2_TABLE_500
    , a30 JTF_VARCHAR2_TABLE_500
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_VARCHAR2_TABLE_500
    , a34 JTF_VARCHAR2_TABLE_500
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_VARCHAR2_TABLE_500
    , a44 JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cleb_fee_id := a0(indx);
          t(ddindx).dnz_chr_id := a1(indx);
          t(ddindx).fee_type := a2(indx);
          t(ddindx).cim_fee_id := a3(indx);
          t(ddindx).cim_fee_sty_name := a4(indx);
          t(ddindx).cim_fee_object1_id1 := a5(indx);
          t(ddindx).cim_fee_object1_id2 := a6(indx);
          t(ddindx).cplb_fee_id := a7(indx);
          t(ddindx).cplb_fee_vendor_name := a8(indx);
          t(ddindx).cplb_fee_object1_id1 := a9(indx);
          t(ddindx).cplb_fee_object1_id2 := a10(indx);
          t(ddindx).start_date := a11(indx);
          t(ddindx).end_date := a12(indx);
          t(ddindx).amount := a13(indx);
          t(ddindx).initial_direct_cost := a14(indx);
          t(ddindx).rollover_term_quote_number := a15(indx);
          t(ddindx).qte_id := a16(indx);
          t(ddindx).funding_date := a17(indx);
          t(ddindx).fee_purpose_code := a18(indx);
          t(ddindx).attribute_category := a19(indx);
          t(ddindx).attribute1 := a20(indx);
          t(ddindx).attribute2 := a21(indx);
          t(ddindx).attribute3 := a22(indx);
          t(ddindx).attribute4 := a23(indx);
          t(ddindx).attribute5 := a24(indx);
          t(ddindx).attribute6 := a25(indx);
          t(ddindx).attribute7 := a26(indx);
          t(ddindx).attribute8 := a27(indx);
          t(ddindx).attribute9 := a28(indx);
          t(ddindx).attribute10 := a29(indx);
          t(ddindx).attribute11 := a30(indx);
          t(ddindx).attribute12 := a31(indx);
          t(ddindx).attribute13 := a32(indx);
          t(ddindx).attribute14 := a33(indx);
          t(ddindx).attribute15 := a34(indx);
          t(ddindx).validate_dff_yn := a35(indx);
          t(ddindx).rgp_lafexp_id := a36(indx);
          t(ddindx).rul_lafreq_id := a37(indx);
          t(ddindx).rul_lafreq_object1_id1 := a38(indx);
          t(ddindx).rul_lafreq_object1_id2 := a39(indx);
          t(ddindx).rul_lafreq_object1_code := a40(indx);
          t(ddindx).frequency_name := a41(indx);
          t(ddindx).rul_lafexp_id := a42(indx);
          t(ddindx).rul_lafexp_rule_information1 := a43(indx);
          t(ddindx).rul_lafexp_rule_information2 := a44(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t okl_deal_charges_pvt.fee_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_400
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_500
    , a21 out nocopy JTF_VARCHAR2_TABLE_500
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_VARCHAR2_TABLE_500
    , a28 out nocopy JTF_VARCHAR2_TABLE_500
    , a29 out nocopy JTF_VARCHAR2_TABLE_500
    , a30 out nocopy JTF_VARCHAR2_TABLE_500
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_VARCHAR2_TABLE_500
    , a34 out nocopy JTF_VARCHAR2_TABLE_500
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_NUMBER_TABLE
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_VARCHAR2_TABLE_500
    , a44 out nocopy JTF_VARCHAR2_TABLE_500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_400();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_500();
    a21 := JTF_VARCHAR2_TABLE_500();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_VARCHAR2_TABLE_500();
    a28 := JTF_VARCHAR2_TABLE_500();
    a29 := JTF_VARCHAR2_TABLE_500();
    a30 := JTF_VARCHAR2_TABLE_500();
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_VARCHAR2_TABLE_500();
    a34 := JTF_VARCHAR2_TABLE_500();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_NUMBER_TABLE();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_VARCHAR2_TABLE_500();
    a44 := JTF_VARCHAR2_TABLE_500();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_400();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_500();
      a21 := JTF_VARCHAR2_TABLE_500();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_VARCHAR2_TABLE_500();
      a28 := JTF_VARCHAR2_TABLE_500();
      a29 := JTF_VARCHAR2_TABLE_500();
      a30 := JTF_VARCHAR2_TABLE_500();
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_VARCHAR2_TABLE_500();
      a34 := JTF_VARCHAR2_TABLE_500();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_NUMBER_TABLE();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_VARCHAR2_TABLE_500();
      a44 := JTF_VARCHAR2_TABLE_500();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cleb_fee_id;
          a1(indx) := t(ddindx).dnz_chr_id;
          a2(indx) := t(ddindx).fee_type;
          a3(indx) := t(ddindx).cim_fee_id;
          a4(indx) := t(ddindx).cim_fee_sty_name;
          a5(indx) := t(ddindx).cim_fee_object1_id1;
          a6(indx) := t(ddindx).cim_fee_object1_id2;
          a7(indx) := t(ddindx).cplb_fee_id;
          a8(indx) := t(ddindx).cplb_fee_vendor_name;
          a9(indx) := t(ddindx).cplb_fee_object1_id1;
          a10(indx) := t(ddindx).cplb_fee_object1_id2;
          a11(indx) := t(ddindx).start_date;
          a12(indx) := t(ddindx).end_date;
          a13(indx) := t(ddindx).amount;
          a14(indx) := t(ddindx).initial_direct_cost;
          a15(indx) := t(ddindx).rollover_term_quote_number;
          a16(indx) := t(ddindx).qte_id;
          a17(indx) := t(ddindx).funding_date;
          a18(indx) := t(ddindx).fee_purpose_code;
          a19(indx) := t(ddindx).attribute_category;
          a20(indx) := t(ddindx).attribute1;
          a21(indx) := t(ddindx).attribute2;
          a22(indx) := t(ddindx).attribute3;
          a23(indx) := t(ddindx).attribute4;
          a24(indx) := t(ddindx).attribute5;
          a25(indx) := t(ddindx).attribute6;
          a26(indx) := t(ddindx).attribute7;
          a27(indx) := t(ddindx).attribute8;
          a28(indx) := t(ddindx).attribute9;
          a29(indx) := t(ddindx).attribute10;
          a30(indx) := t(ddindx).attribute11;
          a31(indx) := t(ddindx).attribute12;
          a32(indx) := t(ddindx).attribute13;
          a33(indx) := t(ddindx).attribute14;
          a34(indx) := t(ddindx).attribute15;
          a35(indx) := t(ddindx).validate_dff_yn;
          a36(indx) := t(ddindx).rgp_lafexp_id;
          a37(indx) := t(ddindx).rul_lafreq_id;
          a38(indx) := t(ddindx).rul_lafreq_object1_id1;
          a39(indx) := t(ddindx).rul_lafreq_object1_id2;
          a40(indx) := t(ddindx).rul_lafreq_object1_code;
          a41(indx) := t(ddindx).frequency_name;
          a42(indx) := t(ddindx).rul_lafexp_id;
          a43(indx) := t(ddindx).rul_lafexp_rule_information1;
          a44(indx) := t(ddindx).rul_lafexp_rule_information2;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure rosetta_table_copy_in_p15(t out nocopy okl_deal_charges_pvt.cov_asset_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cleb_cov_asset_id := a0(indx);
          t(ddindx).cleb_cov_asset_cle_id := a1(indx);
          t(ddindx).dnz_chr_id := a2(indx);
          t(ddindx).asset_number := a3(indx);
          t(ddindx).description := a4(indx);
          t(ddindx).capital_amount := a5(indx);
          t(ddindx).cim_cov_asset_id := a6(indx);
          t(ddindx).object1_id1 := a7(indx);
          t(ddindx).object1_id2 := a8(indx);
          t(ddindx).jtot_object1_code := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p15;
  procedure rosetta_table_copy_out_p15(t okl_deal_charges_pvt.cov_asset_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).cleb_cov_asset_id;
          a1(indx) := t(ddindx).cleb_cov_asset_cle_id;
          a2(indx) := t(ddindx).dnz_chr_id;
          a3(indx) := t(ddindx).asset_number;
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).capital_amount;
          a6(indx) := t(ddindx).cim_cov_asset_id;
          a7(indx) := t(ddindx).object1_id1;
          a8(indx) := t(ddindx).object1_id2;
          a9(indx) := t(ddindx).jtot_object1_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p15;

  procedure allocate_amount_charges(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_cle_id  NUMBER
    , p_amount  NUMBER
    , p_mode  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_cov_asset_tbl okl_deal_charges_pvt.cov_asset_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    okl_deal_charges_pvt.allocate_amount_charges(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_cle_id,
      p_amount,
      p_mode,
      ddx_cov_asset_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    okl_deal_charges_pvt_w.rosetta_table_copy_out_p15(ddx_cov_asset_tbl, p9_a0
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
  end;

  procedure create_fee(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  DATE
    , p5_a12  DATE
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  NUMBER
    , p5_a17  DATE
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  NUMBER
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
  )

  as
    ddp_fee_rec okl_deal_charges_pvt.fee_rec_type;
    ddx_fee_rec okl_deal_charges_pvt.fee_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fee_rec.cleb_fee_id := p5_a0;
    ddp_fee_rec.dnz_chr_id := p5_a1;
    ddp_fee_rec.fee_type := p5_a2;
    ddp_fee_rec.cim_fee_id := p5_a3;
    ddp_fee_rec.cim_fee_sty_name := p5_a4;
    ddp_fee_rec.cim_fee_object1_id1 := p5_a5;
    ddp_fee_rec.cim_fee_object1_id2 := p5_a6;
    ddp_fee_rec.cplb_fee_id := p5_a7;
    ddp_fee_rec.cplb_fee_vendor_name := p5_a8;
    ddp_fee_rec.cplb_fee_object1_id1 := p5_a9;
    ddp_fee_rec.cplb_fee_object1_id2 := p5_a10;
    ddp_fee_rec.start_date := p5_a11;
    ddp_fee_rec.end_date := p5_a12;
    ddp_fee_rec.amount := p5_a13;
    ddp_fee_rec.initial_direct_cost := p5_a14;
    ddp_fee_rec.rollover_term_quote_number := p5_a15;
    ddp_fee_rec.qte_id := p5_a16;
    ddp_fee_rec.funding_date := p5_a17;
    ddp_fee_rec.fee_purpose_code := p5_a18;
    ddp_fee_rec.attribute_category := p5_a19;
    ddp_fee_rec.attribute1 := p5_a20;
    ddp_fee_rec.attribute2 := p5_a21;
    ddp_fee_rec.attribute3 := p5_a22;
    ddp_fee_rec.attribute4 := p5_a23;
    ddp_fee_rec.attribute5 := p5_a24;
    ddp_fee_rec.attribute6 := p5_a25;
    ddp_fee_rec.attribute7 := p5_a26;
    ddp_fee_rec.attribute8 := p5_a27;
    ddp_fee_rec.attribute9 := p5_a28;
    ddp_fee_rec.attribute10 := p5_a29;
    ddp_fee_rec.attribute11 := p5_a30;
    ddp_fee_rec.attribute12 := p5_a31;
    ddp_fee_rec.attribute13 := p5_a32;
    ddp_fee_rec.attribute14 := p5_a33;
    ddp_fee_rec.attribute15 := p5_a34;
    ddp_fee_rec.validate_dff_yn := p5_a35;
    ddp_fee_rec.rgp_lafexp_id := p5_a36;
    ddp_fee_rec.rul_lafreq_id := p5_a37;
    ddp_fee_rec.rul_lafreq_object1_id1 := p5_a38;
    ddp_fee_rec.rul_lafreq_object1_id2 := p5_a39;
    ddp_fee_rec.rul_lafreq_object1_code := p5_a40;
    ddp_fee_rec.frequency_name := p5_a41;
    ddp_fee_rec.rul_lafexp_id := p5_a42;
    ddp_fee_rec.rul_lafexp_rule_information1 := p5_a43;
    ddp_fee_rec.rul_lafexp_rule_information2 := p5_a44;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_charges_pvt.create_fee(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fee_rec,
      ddx_fee_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_fee_rec.cleb_fee_id;
    p6_a1 := ddx_fee_rec.dnz_chr_id;
    p6_a2 := ddx_fee_rec.fee_type;
    p6_a3 := ddx_fee_rec.cim_fee_id;
    p6_a4 := ddx_fee_rec.cim_fee_sty_name;
    p6_a5 := ddx_fee_rec.cim_fee_object1_id1;
    p6_a6 := ddx_fee_rec.cim_fee_object1_id2;
    p6_a7 := ddx_fee_rec.cplb_fee_id;
    p6_a8 := ddx_fee_rec.cplb_fee_vendor_name;
    p6_a9 := ddx_fee_rec.cplb_fee_object1_id1;
    p6_a10 := ddx_fee_rec.cplb_fee_object1_id2;
    p6_a11 := ddx_fee_rec.start_date;
    p6_a12 := ddx_fee_rec.end_date;
    p6_a13 := ddx_fee_rec.amount;
    p6_a14 := ddx_fee_rec.initial_direct_cost;
    p6_a15 := ddx_fee_rec.rollover_term_quote_number;
    p6_a16 := ddx_fee_rec.qte_id;
    p6_a17 := ddx_fee_rec.funding_date;
    p6_a18 := ddx_fee_rec.fee_purpose_code;
    p6_a19 := ddx_fee_rec.attribute_category;
    p6_a20 := ddx_fee_rec.attribute1;
    p6_a21 := ddx_fee_rec.attribute2;
    p6_a22 := ddx_fee_rec.attribute3;
    p6_a23 := ddx_fee_rec.attribute4;
    p6_a24 := ddx_fee_rec.attribute5;
    p6_a25 := ddx_fee_rec.attribute6;
    p6_a26 := ddx_fee_rec.attribute7;
    p6_a27 := ddx_fee_rec.attribute8;
    p6_a28 := ddx_fee_rec.attribute9;
    p6_a29 := ddx_fee_rec.attribute10;
    p6_a30 := ddx_fee_rec.attribute11;
    p6_a31 := ddx_fee_rec.attribute12;
    p6_a32 := ddx_fee_rec.attribute13;
    p6_a33 := ddx_fee_rec.attribute14;
    p6_a34 := ddx_fee_rec.attribute15;
    p6_a35 := ddx_fee_rec.validate_dff_yn;
    p6_a36 := ddx_fee_rec.rgp_lafexp_id;
    p6_a37 := ddx_fee_rec.rul_lafreq_id;
    p6_a38 := ddx_fee_rec.rul_lafreq_object1_id1;
    p6_a39 := ddx_fee_rec.rul_lafreq_object1_id2;
    p6_a40 := ddx_fee_rec.rul_lafreq_object1_code;
    p6_a41 := ddx_fee_rec.frequency_name;
    p6_a42 := ddx_fee_rec.rul_lafexp_id;
    p6_a43 := ddx_fee_rec.rul_lafexp_rule_information1;
    p6_a44 := ddx_fee_rec.rul_lafexp_rule_information2;
  end;

  procedure update_fee(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  DATE
    , p5_a12  DATE
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  NUMBER
    , p5_a17  DATE
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
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  NUMBER
    , p5_a37  NUMBER
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  NUMBER
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  DATE
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  DATE
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
  )

  as
    ddp_fee_rec okl_deal_charges_pvt.fee_rec_type;
    ddx_fee_rec okl_deal_charges_pvt.fee_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_fee_rec.cleb_fee_id := p5_a0;
    ddp_fee_rec.dnz_chr_id := p5_a1;
    ddp_fee_rec.fee_type := p5_a2;
    ddp_fee_rec.cim_fee_id := p5_a3;
    ddp_fee_rec.cim_fee_sty_name := p5_a4;
    ddp_fee_rec.cim_fee_object1_id1 := p5_a5;
    ddp_fee_rec.cim_fee_object1_id2 := p5_a6;
    ddp_fee_rec.cplb_fee_id := p5_a7;
    ddp_fee_rec.cplb_fee_vendor_name := p5_a8;
    ddp_fee_rec.cplb_fee_object1_id1 := p5_a9;
    ddp_fee_rec.cplb_fee_object1_id2 := p5_a10;
    ddp_fee_rec.start_date := p5_a11;
    ddp_fee_rec.end_date := p5_a12;
    ddp_fee_rec.amount := p5_a13;
    ddp_fee_rec.initial_direct_cost := p5_a14;
    ddp_fee_rec.rollover_term_quote_number := p5_a15;
    ddp_fee_rec.qte_id := p5_a16;
    ddp_fee_rec.funding_date := p5_a17;
    ddp_fee_rec.fee_purpose_code := p5_a18;
    ddp_fee_rec.attribute_category := p5_a19;
    ddp_fee_rec.attribute1 := p5_a20;
    ddp_fee_rec.attribute2 := p5_a21;
    ddp_fee_rec.attribute3 := p5_a22;
    ddp_fee_rec.attribute4 := p5_a23;
    ddp_fee_rec.attribute5 := p5_a24;
    ddp_fee_rec.attribute6 := p5_a25;
    ddp_fee_rec.attribute7 := p5_a26;
    ddp_fee_rec.attribute8 := p5_a27;
    ddp_fee_rec.attribute9 := p5_a28;
    ddp_fee_rec.attribute10 := p5_a29;
    ddp_fee_rec.attribute11 := p5_a30;
    ddp_fee_rec.attribute12 := p5_a31;
    ddp_fee_rec.attribute13 := p5_a32;
    ddp_fee_rec.attribute14 := p5_a33;
    ddp_fee_rec.attribute15 := p5_a34;
    ddp_fee_rec.validate_dff_yn := p5_a35;
    ddp_fee_rec.rgp_lafexp_id := p5_a36;
    ddp_fee_rec.rul_lafreq_id := p5_a37;
    ddp_fee_rec.rul_lafreq_object1_id1 := p5_a38;
    ddp_fee_rec.rul_lafreq_object1_id2 := p5_a39;
    ddp_fee_rec.rul_lafreq_object1_code := p5_a40;
    ddp_fee_rec.frequency_name := p5_a41;
    ddp_fee_rec.rul_lafexp_id := p5_a42;
    ddp_fee_rec.rul_lafexp_rule_information1 := p5_a43;
    ddp_fee_rec.rul_lafexp_rule_information2 := p5_a44;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_charges_pvt.update_fee(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_fee_rec,
      ddx_fee_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_fee_rec.cleb_fee_id;
    p6_a1 := ddx_fee_rec.dnz_chr_id;
    p6_a2 := ddx_fee_rec.fee_type;
    p6_a3 := ddx_fee_rec.cim_fee_id;
    p6_a4 := ddx_fee_rec.cim_fee_sty_name;
    p6_a5 := ddx_fee_rec.cim_fee_object1_id1;
    p6_a6 := ddx_fee_rec.cim_fee_object1_id2;
    p6_a7 := ddx_fee_rec.cplb_fee_id;
    p6_a8 := ddx_fee_rec.cplb_fee_vendor_name;
    p6_a9 := ddx_fee_rec.cplb_fee_object1_id1;
    p6_a10 := ddx_fee_rec.cplb_fee_object1_id2;
    p6_a11 := ddx_fee_rec.start_date;
    p6_a12 := ddx_fee_rec.end_date;
    p6_a13 := ddx_fee_rec.amount;
    p6_a14 := ddx_fee_rec.initial_direct_cost;
    p6_a15 := ddx_fee_rec.rollover_term_quote_number;
    p6_a16 := ddx_fee_rec.qte_id;
    p6_a17 := ddx_fee_rec.funding_date;
    p6_a18 := ddx_fee_rec.fee_purpose_code;
    p6_a19 := ddx_fee_rec.attribute_category;
    p6_a20 := ddx_fee_rec.attribute1;
    p6_a21 := ddx_fee_rec.attribute2;
    p6_a22 := ddx_fee_rec.attribute3;
    p6_a23 := ddx_fee_rec.attribute4;
    p6_a24 := ddx_fee_rec.attribute5;
    p6_a25 := ddx_fee_rec.attribute6;
    p6_a26 := ddx_fee_rec.attribute7;
    p6_a27 := ddx_fee_rec.attribute8;
    p6_a28 := ddx_fee_rec.attribute9;
    p6_a29 := ddx_fee_rec.attribute10;
    p6_a30 := ddx_fee_rec.attribute11;
    p6_a31 := ddx_fee_rec.attribute12;
    p6_a32 := ddx_fee_rec.attribute13;
    p6_a33 := ddx_fee_rec.attribute14;
    p6_a34 := ddx_fee_rec.attribute15;
    p6_a35 := ddx_fee_rec.validate_dff_yn;
    p6_a36 := ddx_fee_rec.rgp_lafexp_id;
    p6_a37 := ddx_fee_rec.rul_lafreq_id;
    p6_a38 := ddx_fee_rec.rul_lafreq_object1_id1;
    p6_a39 := ddx_fee_rec.rul_lafreq_object1_id2;
    p6_a40 := ddx_fee_rec.rul_lafreq_object1_code;
    p6_a41 := ddx_fee_rec.frequency_name;
    p6_a42 := ddx_fee_rec.rul_lafexp_id;
    p6_a43 := ddx_fee_rec.rul_lafexp_rule_information1;
    p6_a44 := ddx_fee_rec.rul_lafexp_rule_information2;
  end;

end okl_deal_charges_pvt_w;

/
