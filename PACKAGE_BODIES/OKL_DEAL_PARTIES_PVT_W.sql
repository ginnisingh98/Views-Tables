--------------------------------------------------------
--  DDL for Package Body OKL_DEAL_PARTIES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEAL_PARTIES_PVT_W" as
  /* $Header: OKLEDPRB.pls 120.0 2007/07/03 09:03:28 rviriyal noship $ */
  procedure process_label_holder(p_api_version  NUMBER
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
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  NUMBER
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
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
  )

  as
    ddp_rgpv_rec okl_deal_parties_pvt.party_role_rec_type;
    ddx_rgpv_rec okl_deal_parties_pvt.party_role_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.chr_id := p5_a0;
    ddp_rgpv_rec.party_role_id := p5_a1;
    ddp_rgpv_rec.party_role := p5_a2;
    ddp_rgpv_rec.party_id := p5_a3;
    ddp_rgpv_rec.party_name := p5_a4;
    ddp_rgpv_rec.party_site_number := p5_a5;
    ddp_rgpv_rec.rgp_id := p5_a6;
    ddp_rgpv_rec.rgp_lalabl_lalogo_id := p5_a7;
    ddp_rgpv_rec.rgp_lagrdt_lagrnp_id := p5_a8;
    ddp_rgpv_rec.rgp_lagrdt_lagrnt_id := p5_a9;
    ddp_rgpv_rec.rul_lalogo_id := p5_a10;
    ddp_rgpv_rec.rul_lagrnp_id := p5_a11;
    ddp_rgpv_rec.rul_lagrnt_id := p5_a12;
    ddp_rgpv_rec.lalogo_rule_information1 := p5_a13;
    ddp_rgpv_rec.rul_lagrnp_object1_id1 := p5_a14;
    ddp_rgpv_rec.rul_lagrnp_object1_id2 := p5_a15;
    ddp_rgpv_rec.lagrnp_rule_info_cat := p5_a16;
    ddp_rgpv_rec.lagrnp_rule_information1 := p5_a17;
    ddp_rgpv_rec.lagrnt_rule_info_cat := p5_a18;
    ddp_rgpv_rec.lagrnt_rule_information1 := p5_a19;
    ddp_rgpv_rec.lagrnt_rule_information2 := p5_a20;
    ddp_rgpv_rec.lagrnt_rule_information3 := p5_a21;
    ddp_rgpv_rec.lagrnt_rule_information4 := p5_a22;
    ddp_rgpv_rec.attribute_category := p5_a23;
    ddp_rgpv_rec.attribute1 := p5_a24;
    ddp_rgpv_rec.attribute2 := p5_a25;
    ddp_rgpv_rec.attribute3 := p5_a26;
    ddp_rgpv_rec.attribute4 := p5_a27;
    ddp_rgpv_rec.attribute5 := p5_a28;
    ddp_rgpv_rec.attribute6 := p5_a29;
    ddp_rgpv_rec.attribute7 := p5_a30;
    ddp_rgpv_rec.attribute8 := p5_a31;
    ddp_rgpv_rec.attribute9 := p5_a32;
    ddp_rgpv_rec.attribute10 := p5_a33;
    ddp_rgpv_rec.attribute11 := p5_a34;
    ddp_rgpv_rec.attribute12 := p5_a35;
    ddp_rgpv_rec.attribute13 := p5_a36;
    ddp_rgpv_rec.attribute14 := p5_a37;
    ddp_rgpv_rec.attribute15 := p5_a38;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_parties_pvt.process_label_holder(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rgpv_rec.chr_id;
    p6_a1 := ddx_rgpv_rec.party_role_id;
    p6_a2 := ddx_rgpv_rec.party_role;
    p6_a3 := ddx_rgpv_rec.party_id;
    p6_a4 := ddx_rgpv_rec.party_name;
    p6_a5 := ddx_rgpv_rec.party_site_number;
    p6_a6 := ddx_rgpv_rec.rgp_id;
    p6_a7 := ddx_rgpv_rec.rgp_lalabl_lalogo_id;
    p6_a8 := ddx_rgpv_rec.rgp_lagrdt_lagrnp_id;
    p6_a9 := ddx_rgpv_rec.rgp_lagrdt_lagrnt_id;
    p6_a10 := ddx_rgpv_rec.rul_lalogo_id;
    p6_a11 := ddx_rgpv_rec.rul_lagrnp_id;
    p6_a12 := ddx_rgpv_rec.rul_lagrnt_id;
    p6_a13 := ddx_rgpv_rec.lalogo_rule_information1;
    p6_a14 := ddx_rgpv_rec.rul_lagrnp_object1_id1;
    p6_a15 := ddx_rgpv_rec.rul_lagrnp_object1_id2;
    p6_a16 := ddx_rgpv_rec.lagrnp_rule_info_cat;
    p6_a17 := ddx_rgpv_rec.lagrnp_rule_information1;
    p6_a18 := ddx_rgpv_rec.lagrnt_rule_info_cat;
    p6_a19 := ddx_rgpv_rec.lagrnt_rule_information1;
    p6_a20 := ddx_rgpv_rec.lagrnt_rule_information2;
    p6_a21 := ddx_rgpv_rec.lagrnt_rule_information3;
    p6_a22 := ddx_rgpv_rec.lagrnt_rule_information4;
    p6_a23 := ddx_rgpv_rec.attribute_category;
    p6_a24 := ddx_rgpv_rec.attribute1;
    p6_a25 := ddx_rgpv_rec.attribute2;
    p6_a26 := ddx_rgpv_rec.attribute3;
    p6_a27 := ddx_rgpv_rec.attribute4;
    p6_a28 := ddx_rgpv_rec.attribute5;
    p6_a29 := ddx_rgpv_rec.attribute6;
    p6_a30 := ddx_rgpv_rec.attribute7;
    p6_a31 := ddx_rgpv_rec.attribute8;
    p6_a32 := ddx_rgpv_rec.attribute9;
    p6_a33 := ddx_rgpv_rec.attribute10;
    p6_a34 := ddx_rgpv_rec.attribute11;
    p6_a35 := ddx_rgpv_rec.attribute12;
    p6_a36 := ddx_rgpv_rec.attribute13;
    p6_a37 := ddx_rgpv_rec.attribute14;
    p6_a38 := ddx_rgpv_rec.attribute15;
  end;

  procedure load_guarantor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_party_id  NUMBER
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
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
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
  )

  as
    ddx_party_role_rec okl_deal_parties_pvt.party_role_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    okl_deal_parties_pvt.load_guarantor(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_party_id,
      ddx_party_role_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_party_role_rec.chr_id;
    p7_a1 := ddx_party_role_rec.party_role_id;
    p7_a2 := ddx_party_role_rec.party_role;
    p7_a3 := ddx_party_role_rec.party_id;
    p7_a4 := ddx_party_role_rec.party_name;
    p7_a5 := ddx_party_role_rec.party_site_number;
    p7_a6 := ddx_party_role_rec.rgp_id;
    p7_a7 := ddx_party_role_rec.rgp_lalabl_lalogo_id;
    p7_a8 := ddx_party_role_rec.rgp_lagrdt_lagrnp_id;
    p7_a9 := ddx_party_role_rec.rgp_lagrdt_lagrnt_id;
    p7_a10 := ddx_party_role_rec.rul_lalogo_id;
    p7_a11 := ddx_party_role_rec.rul_lagrnp_id;
    p7_a12 := ddx_party_role_rec.rul_lagrnt_id;
    p7_a13 := ddx_party_role_rec.lalogo_rule_information1;
    p7_a14 := ddx_party_role_rec.rul_lagrnp_object1_id1;
    p7_a15 := ddx_party_role_rec.rul_lagrnp_object1_id2;
    p7_a16 := ddx_party_role_rec.lagrnp_rule_info_cat;
    p7_a17 := ddx_party_role_rec.lagrnp_rule_information1;
    p7_a18 := ddx_party_role_rec.lagrnt_rule_info_cat;
    p7_a19 := ddx_party_role_rec.lagrnt_rule_information1;
    p7_a20 := ddx_party_role_rec.lagrnt_rule_information2;
    p7_a21 := ddx_party_role_rec.lagrnt_rule_information3;
    p7_a22 := ddx_party_role_rec.lagrnt_rule_information4;
    p7_a23 := ddx_party_role_rec.attribute_category;
    p7_a24 := ddx_party_role_rec.attribute1;
    p7_a25 := ddx_party_role_rec.attribute2;
    p7_a26 := ddx_party_role_rec.attribute3;
    p7_a27 := ddx_party_role_rec.attribute4;
    p7_a28 := ddx_party_role_rec.attribute5;
    p7_a29 := ddx_party_role_rec.attribute6;
    p7_a30 := ddx_party_role_rec.attribute7;
    p7_a31 := ddx_party_role_rec.attribute8;
    p7_a32 := ddx_party_role_rec.attribute9;
    p7_a33 := ddx_party_role_rec.attribute10;
    p7_a34 := ddx_party_role_rec.attribute11;
    p7_a35 := ddx_party_role_rec.attribute12;
    p7_a36 := ddx_party_role_rec.attribute13;
    p7_a37 := ddx_party_role_rec.attribute14;
    p7_a38 := ddx_party_role_rec.attribute15;
  end;

  procedure process_guarantor(p_api_version  NUMBER
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
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  NUMBER
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
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
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
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
  )

  as
    ddp_rgpv_rec okl_deal_parties_pvt.party_role_rec_type;
    ddx_rgpv_rec okl_deal_parties_pvt.party_role_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rgpv_rec.chr_id := p5_a0;
    ddp_rgpv_rec.party_role_id := p5_a1;
    ddp_rgpv_rec.party_role := p5_a2;
    ddp_rgpv_rec.party_id := p5_a3;
    ddp_rgpv_rec.party_name := p5_a4;
    ddp_rgpv_rec.party_site_number := p5_a5;
    ddp_rgpv_rec.rgp_id := p5_a6;
    ddp_rgpv_rec.rgp_lalabl_lalogo_id := p5_a7;
    ddp_rgpv_rec.rgp_lagrdt_lagrnp_id := p5_a8;
    ddp_rgpv_rec.rgp_lagrdt_lagrnt_id := p5_a9;
    ddp_rgpv_rec.rul_lalogo_id := p5_a10;
    ddp_rgpv_rec.rul_lagrnp_id := p5_a11;
    ddp_rgpv_rec.rul_lagrnt_id := p5_a12;
    ddp_rgpv_rec.lalogo_rule_information1 := p5_a13;
    ddp_rgpv_rec.rul_lagrnp_object1_id1 := p5_a14;
    ddp_rgpv_rec.rul_lagrnp_object1_id2 := p5_a15;
    ddp_rgpv_rec.lagrnp_rule_info_cat := p5_a16;
    ddp_rgpv_rec.lagrnp_rule_information1 := p5_a17;
    ddp_rgpv_rec.lagrnt_rule_info_cat := p5_a18;
    ddp_rgpv_rec.lagrnt_rule_information1 := p5_a19;
    ddp_rgpv_rec.lagrnt_rule_information2 := p5_a20;
    ddp_rgpv_rec.lagrnt_rule_information3 := p5_a21;
    ddp_rgpv_rec.lagrnt_rule_information4 := p5_a22;
    ddp_rgpv_rec.attribute_category := p5_a23;
    ddp_rgpv_rec.attribute1 := p5_a24;
    ddp_rgpv_rec.attribute2 := p5_a25;
    ddp_rgpv_rec.attribute3 := p5_a26;
    ddp_rgpv_rec.attribute4 := p5_a27;
    ddp_rgpv_rec.attribute5 := p5_a28;
    ddp_rgpv_rec.attribute6 := p5_a29;
    ddp_rgpv_rec.attribute7 := p5_a30;
    ddp_rgpv_rec.attribute8 := p5_a31;
    ddp_rgpv_rec.attribute9 := p5_a32;
    ddp_rgpv_rec.attribute10 := p5_a33;
    ddp_rgpv_rec.attribute11 := p5_a34;
    ddp_rgpv_rec.attribute12 := p5_a35;
    ddp_rgpv_rec.attribute13 := p5_a36;
    ddp_rgpv_rec.attribute14 := p5_a37;
    ddp_rgpv_rec.attribute15 := p5_a38;


    -- here's the delegated call to the old PL/SQL routine
    okl_deal_parties_pvt.process_guarantor(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rgpv_rec,
      ddx_rgpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_rgpv_rec.chr_id;
    p6_a1 := ddx_rgpv_rec.party_role_id;
    p6_a2 := ddx_rgpv_rec.party_role;
    p6_a3 := ddx_rgpv_rec.party_id;
    p6_a4 := ddx_rgpv_rec.party_name;
    p6_a5 := ddx_rgpv_rec.party_site_number;
    p6_a6 := ddx_rgpv_rec.rgp_id;
    p6_a7 := ddx_rgpv_rec.rgp_lalabl_lalogo_id;
    p6_a8 := ddx_rgpv_rec.rgp_lagrdt_lagrnp_id;
    p6_a9 := ddx_rgpv_rec.rgp_lagrdt_lagrnt_id;
    p6_a10 := ddx_rgpv_rec.rul_lalogo_id;
    p6_a11 := ddx_rgpv_rec.rul_lagrnp_id;
    p6_a12 := ddx_rgpv_rec.rul_lagrnt_id;
    p6_a13 := ddx_rgpv_rec.lalogo_rule_information1;
    p6_a14 := ddx_rgpv_rec.rul_lagrnp_object1_id1;
    p6_a15 := ddx_rgpv_rec.rul_lagrnp_object1_id2;
    p6_a16 := ddx_rgpv_rec.lagrnp_rule_info_cat;
    p6_a17 := ddx_rgpv_rec.lagrnp_rule_information1;
    p6_a18 := ddx_rgpv_rec.lagrnt_rule_info_cat;
    p6_a19 := ddx_rgpv_rec.lagrnt_rule_information1;
    p6_a20 := ddx_rgpv_rec.lagrnt_rule_information2;
    p6_a21 := ddx_rgpv_rec.lagrnt_rule_information3;
    p6_a22 := ddx_rgpv_rec.lagrnt_rule_information4;
    p6_a23 := ddx_rgpv_rec.attribute_category;
    p6_a24 := ddx_rgpv_rec.attribute1;
    p6_a25 := ddx_rgpv_rec.attribute2;
    p6_a26 := ddx_rgpv_rec.attribute3;
    p6_a27 := ddx_rgpv_rec.attribute4;
    p6_a28 := ddx_rgpv_rec.attribute5;
    p6_a29 := ddx_rgpv_rec.attribute6;
    p6_a30 := ddx_rgpv_rec.attribute7;
    p6_a31 := ddx_rgpv_rec.attribute8;
    p6_a32 := ddx_rgpv_rec.attribute9;
    p6_a33 := ddx_rgpv_rec.attribute10;
    p6_a34 := ddx_rgpv_rec.attribute11;
    p6_a35 := ddx_rgpv_rec.attribute12;
    p6_a36 := ddx_rgpv_rec.attribute13;
    p6_a37 := ddx_rgpv_rec.attribute14;
    p6_a38 := ddx_rgpv_rec.attribute15;
  end;

end okl_deal_parties_pvt_w;

/
