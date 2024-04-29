--------------------------------------------------------
--  DDL for Package Body OKL_DEAL_TERMS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEAL_TERMS_PVT_W" as
  /* $Header: OKLEDTRB.pls 120.0 2007/03/28 13:43:39 udhenuko noship $ */
  procedure process_billing_setup(p_api_version  NUMBER
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
    okl_deal_terms_pvt.process_billing_setup(p_api_version,
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

  procedure process_rvi(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  VARCHAR2
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  VARCHAR2
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  NUMBER
    , p5_a14  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
  )

  as
    ddp_rgpv_rec okl_deal_terms_pvt.rvi_rec_type;
    ddx_rgpv_rec okl_deal_terms_pvt.rvi_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.line_id := p5_a0;
    ddp_rgpv_rec.chr_id := p5_a1;
    ddp_rgpv_rec.fee_type := p5_a2;
    ddp_rgpv_rec.rgp_id := p5_a3;
    ddp_rgpv_rec.rgd_code := p5_a4;
    ddp_rgpv_rec.rgp_larvin_larvau_id := p5_a5;
    ddp_rgpv_rec.rgp_larvin_larvam_id := p5_a6;
    ddp_rgpv_rec.rul_larvau_id := p5_a7;
    ddp_rgpv_rec.larvau_rule_info_cat := p5_a8;
    ddp_rgpv_rec.rul_larvam_id := p5_a9;
    ddp_rgpv_rec.larvam_rule_info_cat := p5_a10;
    ddp_rgpv_rec.larvau_rule_information1 := p5_a11;
    ddp_rgpv_rec.larvam_rule_information4 := p5_a12;
    ddp_rgpv_rec.item_id1 := p5_a13;
    ddp_rgpv_rec.item_name := p5_a14;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_terms_pvt.process_rvi(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rgpv_rec.line_id;
    p6_a1 := ddx_rgpv_rec.chr_id;
    p6_a2 := ddx_rgpv_rec.fee_type;
    p6_a3 := ddx_rgpv_rec.rgp_id;
    p6_a4 := ddx_rgpv_rec.rgd_code;
    p6_a5 := ddx_rgpv_rec.rgp_larvin_larvau_id;
    p6_a6 := ddx_rgpv_rec.rgp_larvin_larvam_id;
    p6_a7 := ddx_rgpv_rec.rul_larvau_id;
    p6_a8 := ddx_rgpv_rec.larvau_rule_info_cat;
    p6_a9 := ddx_rgpv_rec.rul_larvam_id;
    p6_a10 := ddx_rgpv_rec.larvam_rule_info_cat;
    p6_a11 := ddx_rgpv_rec.larvau_rule_information1;
    p6_a12 := ddx_rgpv_rec.larvam_rule_information4;
    p6_a13 := ddx_rgpv_rec.item_id1;
    p6_a14 := ddx_rgpv_rec.item_name;
  end;

  procedure load_billing_setup(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
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
    ddx_billing_setup_rec okl_deal_terms_pvt.billing_setup_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_deal_terms_pvt.load_billing_setup(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddx_billing_setup_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_billing_setup_rec.chr_id;
    p6_a1 := ddx_billing_setup_rec.cle_id;
    p6_a2 := ddx_billing_setup_rec.asset_number;
    p6_a3 := ddx_billing_setup_rec.item_description;
    p6_a4 := ddx_billing_setup_rec.rgp_id;
    p6_a5 := ddx_billing_setup_rec.bill_to_site_use_id;
    p6_a6 := ddx_billing_setup_rec.bill_to_site_name;
    p6_a7 := ddx_billing_setup_rec.rgp_labill_lapmth_id;
    p6_a8 := ddx_billing_setup_rec.rgp_labill_labacc_id;
    p6_a9 := ddx_billing_setup_rec.rgp_labill_lainvd_id;
    p6_a10 := ddx_billing_setup_rec.rgp_labill_lainpr_id;
    p6_a11 := ddx_billing_setup_rec.rul_lapmth_id;
    p6_a12 := ddx_billing_setup_rec.rul_labacc_id;
    p6_a13 := ddx_billing_setup_rec.rul_lainvd_id;
    p6_a14 := ddx_billing_setup_rec.rul_lainpr_id;
    p6_a15 := ddx_billing_setup_rec.rul_lapmth_object1_id1;
    p6_a16 := ddx_billing_setup_rec.rul_lapmth_object1_id2;
    p6_a17 := ddx_billing_setup_rec.rul_lapmth_name;
    p6_a18 := ddx_billing_setup_rec.rul_labacc_object1_id1;
    p6_a19 := ddx_billing_setup_rec.rul_labacc_object1_id2;
    p6_a20 := ddx_billing_setup_rec.rul_labacc_name;
    p6_a21 := ddx_billing_setup_rec.rul_labacc_bank_name;
    p6_a22 := ddx_billing_setup_rec.lainvd_invoice_format_meaning;
    p6_a23 := ddx_billing_setup_rec.lainvd_rule_information1;
    p6_a24 := ddx_billing_setup_rec.lainvd_rule_information3;
    p6_a25 := ddx_billing_setup_rec.lainvd_rule_information4;
    p6_a26 := ddx_billing_setup_rec.rul_lainvd_object1_id1;
    p6_a27 := ddx_billing_setup_rec.rul_lainvd_object1_id2;
    p6_a28 := ddx_billing_setup_rec.rul_lainvd_name;
    p6_a29 := ddx_billing_setup_rec.lainpr_rule_information1;
    p6_a30 := ddx_billing_setup_rec.lainpr_rule_information2;
  end;

  procedure load_rvi(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
  )

  as
    ddx_rvi_rec okl_deal_terms_pvt.rvi_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_deal_terms_pvt.load_rvi(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddx_rvi_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rvi_rec.line_id;
    p6_a1 := ddx_rvi_rec.chr_id;
    p6_a2 := ddx_rvi_rec.fee_type;
    p6_a3 := ddx_rvi_rec.rgp_id;
    p6_a4 := ddx_rvi_rec.rgd_code;
    p6_a5 := ddx_rvi_rec.rgp_larvin_larvau_id;
    p6_a6 := ddx_rvi_rec.rgp_larvin_larvam_id;
    p6_a7 := ddx_rvi_rec.rul_larvau_id;
    p6_a8 := ddx_rvi_rec.larvau_rule_info_cat;
    p6_a9 := ddx_rvi_rec.rul_larvam_id;
    p6_a10 := ddx_rvi_rec.larvam_rule_info_cat;
    p6_a11 := ddx_rvi_rec.larvau_rule_information1;
    p6_a12 := ddx_rvi_rec.larvam_rule_information4;
    p6_a13 := ddx_rvi_rec.item_id1;
    p6_a14 := ddx_rvi_rec.item_name;
  end;

end okl_deal_terms_pvt_w;

/
