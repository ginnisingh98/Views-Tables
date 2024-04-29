--------------------------------------------------------
--  DDL for Package Body OKL_SETUPOPTVALUES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPOPTVALUES_PVT_W" as
  /* $Header: OKLESOVB.pls 115.2 2002/12/24 04:02:58 sgorantl noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
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

  procedure get_rec(x_return_status out nocopy  VARCHAR2
    , x_no_data_found out nocopy  number
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  NUMBER
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  DATE
    , p3_a6 out nocopy  DATE
    , p3_a7 out nocopy  NUMBER
    , p3_a8 out nocopy  DATE
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  DATE
    , p3_a11 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  DATE := fnd_api.g_miss_date
    , p0_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_ovev_rec okl_setupoptvalues_pvt.ovev_rec_type;
    ddx_no_data_found boolean;
    ddx_ovev_rec okl_setupoptvalues_pvt.ovev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ovev_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_ovev_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_ovev_rec.opt_id := rosetta_g_miss_num_map(p0_a2);
    ddp_ovev_rec.value := p0_a3;
    ddp_ovev_rec.description := p0_a4;
    ddp_ovev_rec.from_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_ovev_rec.to_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_ovev_rec.created_by := rosetta_g_miss_num_map(p0_a7);
    ddp_ovev_rec.creation_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_ovev_rec.last_updated_by := rosetta_g_miss_num_map(p0_a9);
    ddp_ovev_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a10);
    ddp_ovev_rec.last_update_login := rosetta_g_miss_num_map(p0_a11);




    -- here's the delegated call to the old PL/SQL routine
    okl_setupoptvalues_pvt.get_rec(ddp_ovev_rec,
      x_return_status,
      ddx_no_data_found,
      ddx_ovev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;

    p3_a0 := rosetta_g_miss_num_map(ddx_ovev_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_ovev_rec.object_version_number);
    p3_a2 := rosetta_g_miss_num_map(ddx_ovev_rec.opt_id);
    p3_a3 := ddx_ovev_rec.value;
    p3_a4 := ddx_ovev_rec.description;
    p3_a5 := ddx_ovev_rec.from_date;
    p3_a6 := ddx_ovev_rec.to_date;
    p3_a7 := rosetta_g_miss_num_map(ddx_ovev_rec.created_by);
    p3_a8 := ddx_ovev_rec.creation_date;
    p3_a9 := rosetta_g_miss_num_map(ddx_ovev_rec.last_updated_by);
    p3_a10 := ddx_ovev_rec.last_update_date;
    p3_a11 := rosetta_g_miss_num_map(ddx_ovev_rec.last_update_login);
  end;

  procedure get_rul_rec(x_return_status out nocopy  VARCHAR2
    , x_no_data_found out nocopy  number
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  VARCHAR2
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  VARCHAR2
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  VARCHAR2
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  NUMBER
    , p3_a13 out nocopy  NUMBER
    , p3_a14 out nocopy  NUMBER
    , p3_a15 out nocopy  VARCHAR2
    , p3_a16 out nocopy  VARCHAR2
    , p3_a17 out nocopy  VARCHAR2
    , p3_a18 out nocopy  VARCHAR2
    , p3_a19 out nocopy  VARCHAR2
    , p3_a20 out nocopy  VARCHAR2
    , p3_a21 out nocopy  VARCHAR2
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  VARCHAR2
    , p3_a25 out nocopy  VARCHAR2
    , p3_a26 out nocopy  VARCHAR2
    , p3_a27 out nocopy  VARCHAR2
    , p3_a28 out nocopy  VARCHAR2
    , p3_a29 out nocopy  VARCHAR2
    , p3_a30 out nocopy  VARCHAR2
    , p3_a31 out nocopy  VARCHAR2
    , p3_a32 out nocopy  VARCHAR2
    , p3_a33 out nocopy  VARCHAR2
    , p3_a34 out nocopy  NUMBER
    , p3_a35 out nocopy  DATE
    , p3_a36 out nocopy  NUMBER
    , p3_a37 out nocopy  DATE
    , p3_a38 out nocopy  NUMBER
    , p3_a39 out nocopy  VARCHAR2
    , p3_a40 out nocopy  VARCHAR2
    , p3_a41 out nocopy  VARCHAR2
    , p3_a42 out nocopy  VARCHAR2
    , p3_a43 out nocopy  VARCHAR2
    , p3_a44 out nocopy  VARCHAR2
    , p3_a45 out nocopy  VARCHAR2
    , p3_a46 out nocopy  VARCHAR2
    , p3_a47 out nocopy  VARCHAR2
    , p3_a48 out nocopy  VARCHAR2
    , p3_a49 out nocopy  VARCHAR2
    , p3_a50 out nocopy  VARCHAR2
    , p3_a51 out nocopy  VARCHAR2
    , p3_a52 out nocopy  VARCHAR2
    , p3_a53 out nocopy  VARCHAR2
    , p3_a54 out nocopy  VARCHAR2
    , p3_a55 out nocopy  VARCHAR2
    , p3_a56 out nocopy  VARCHAR2
    , p3_a57 out nocopy  VARCHAR2
    , p3_a58 out nocopy  VARCHAR2
    , p3_a59 out nocopy  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  DATE := fnd_api.g_miss_date
    , p0_a36  NUMBER := 0-1962.0724
    , p0_a37  DATE := fnd_api.g_miss_date
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  NUMBER := 0-1962.0724
  )

  as
    ddp_rulv_rec okl_setupoptvalues_pvt.rulv_rec_type;
    ddx_no_data_found boolean;
    ddx_rulv_rec okl_setupoptvalues_pvt.rulv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_rulv_rec.id := rosetta_g_miss_num_map(p0_a0);
    ddp_rulv_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_rulv_rec.sfwt_flag := p0_a2;
    ddp_rulv_rec.object1_id1 := p0_a3;
    ddp_rulv_rec.object2_id1 := p0_a4;
    ddp_rulv_rec.object3_id1 := p0_a5;
    ddp_rulv_rec.object1_id2 := p0_a6;
    ddp_rulv_rec.object2_id2 := p0_a7;
    ddp_rulv_rec.object3_id2 := p0_a8;
    ddp_rulv_rec.jtot_object1_code := p0_a9;
    ddp_rulv_rec.jtot_object2_code := p0_a10;
    ddp_rulv_rec.jtot_object3_code := p0_a11;
    ddp_rulv_rec.dnz_chr_id := rosetta_g_miss_num_map(p0_a12);
    ddp_rulv_rec.rgp_id := rosetta_g_miss_num_map(p0_a13);
    ddp_rulv_rec.priority := rosetta_g_miss_num_map(p0_a14);
    ddp_rulv_rec.std_template_yn := p0_a15;
    ddp_rulv_rec.comments := p0_a16;
    ddp_rulv_rec.warn_yn := p0_a17;
    ddp_rulv_rec.attribute_category := p0_a18;
    ddp_rulv_rec.attribute1 := p0_a19;
    ddp_rulv_rec.attribute2 := p0_a20;
    ddp_rulv_rec.attribute3 := p0_a21;
    ddp_rulv_rec.attribute4 := p0_a22;
    ddp_rulv_rec.attribute5 := p0_a23;
    ddp_rulv_rec.attribute6 := p0_a24;
    ddp_rulv_rec.attribute7 := p0_a25;
    ddp_rulv_rec.attribute8 := p0_a26;
    ddp_rulv_rec.attribute9 := p0_a27;
    ddp_rulv_rec.attribute10 := p0_a28;
    ddp_rulv_rec.attribute11 := p0_a29;
    ddp_rulv_rec.attribute12 := p0_a30;
    ddp_rulv_rec.attribute13 := p0_a31;
    ddp_rulv_rec.attribute14 := p0_a32;
    ddp_rulv_rec.attribute15 := p0_a33;
    ddp_rulv_rec.created_by := rosetta_g_miss_num_map(p0_a34);
    ddp_rulv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a35);
    ddp_rulv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a36);
    ddp_rulv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a37);
    ddp_rulv_rec.last_update_login := rosetta_g_miss_num_map(p0_a38);
    ddp_rulv_rec.rule_information_category := p0_a39;
    ddp_rulv_rec.rule_information1 := p0_a40;
    ddp_rulv_rec.rule_information2 := p0_a41;
    ddp_rulv_rec.rule_information3 := p0_a42;
    ddp_rulv_rec.rule_information4 := p0_a43;
    ddp_rulv_rec.rule_information5 := p0_a44;
    ddp_rulv_rec.rule_information6 := p0_a45;
    ddp_rulv_rec.rule_information7 := p0_a46;
    ddp_rulv_rec.rule_information8 := p0_a47;
    ddp_rulv_rec.rule_information9 := p0_a48;
    ddp_rulv_rec.rule_information10 := p0_a49;
    ddp_rulv_rec.rule_information11 := p0_a50;
    ddp_rulv_rec.rule_information12 := p0_a51;
    ddp_rulv_rec.rule_information13 := p0_a52;
    ddp_rulv_rec.rule_information14 := p0_a53;
    ddp_rulv_rec.rule_information15 := p0_a54;
    ddp_rulv_rec.template_yn := p0_a55;
    ddp_rulv_rec.ans_set_jtot_object_code := p0_a56;
    ddp_rulv_rec.ans_set_jtot_object_id1 := p0_a57;
    ddp_rulv_rec.ans_set_jtot_object_id2 := p0_a58;
    ddp_rulv_rec.display_sequence := rosetta_g_miss_num_map(p0_a59);




    -- here's the delegated call to the old PL/SQL routine
    okl_setupoptvalues_pvt.get_rul_rec(ddp_rulv_rec,
      x_return_status,
      ddx_no_data_found,
      ddx_rulv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;

    p3_a0 := rosetta_g_miss_num_map(ddx_rulv_rec.id);
    p3_a1 := rosetta_g_miss_num_map(ddx_rulv_rec.object_version_number);
    p3_a2 := ddx_rulv_rec.sfwt_flag;
    p3_a3 := ddx_rulv_rec.object1_id1;
    p3_a4 := ddx_rulv_rec.object2_id1;
    p3_a5 := ddx_rulv_rec.object3_id1;
    p3_a6 := ddx_rulv_rec.object1_id2;
    p3_a7 := ddx_rulv_rec.object2_id2;
    p3_a8 := ddx_rulv_rec.object3_id2;
    p3_a9 := ddx_rulv_rec.jtot_object1_code;
    p3_a10 := ddx_rulv_rec.jtot_object2_code;
    p3_a11 := ddx_rulv_rec.jtot_object3_code;
    p3_a12 := rosetta_g_miss_num_map(ddx_rulv_rec.dnz_chr_id);
    p3_a13 := rosetta_g_miss_num_map(ddx_rulv_rec.rgp_id);
    p3_a14 := rosetta_g_miss_num_map(ddx_rulv_rec.priority);
    p3_a15 := ddx_rulv_rec.std_template_yn;
    p3_a16 := ddx_rulv_rec.comments;
    p3_a17 := ddx_rulv_rec.warn_yn;
    p3_a18 := ddx_rulv_rec.attribute_category;
    p3_a19 := ddx_rulv_rec.attribute1;
    p3_a20 := ddx_rulv_rec.attribute2;
    p3_a21 := ddx_rulv_rec.attribute3;
    p3_a22 := ddx_rulv_rec.attribute4;
    p3_a23 := ddx_rulv_rec.attribute5;
    p3_a24 := ddx_rulv_rec.attribute6;
    p3_a25 := ddx_rulv_rec.attribute7;
    p3_a26 := ddx_rulv_rec.attribute8;
    p3_a27 := ddx_rulv_rec.attribute9;
    p3_a28 := ddx_rulv_rec.attribute10;
    p3_a29 := ddx_rulv_rec.attribute11;
    p3_a30 := ddx_rulv_rec.attribute12;
    p3_a31 := ddx_rulv_rec.attribute13;
    p3_a32 := ddx_rulv_rec.attribute14;
    p3_a33 := ddx_rulv_rec.attribute15;
    p3_a34 := rosetta_g_miss_num_map(ddx_rulv_rec.created_by);
    p3_a35 := ddx_rulv_rec.creation_date;
    p3_a36 := rosetta_g_miss_num_map(ddx_rulv_rec.last_updated_by);
    p3_a37 := ddx_rulv_rec.last_update_date;
    p3_a38 := rosetta_g_miss_num_map(ddx_rulv_rec.last_update_login);
    p3_a39 := ddx_rulv_rec.rule_information_category;
    p3_a40 := ddx_rulv_rec.rule_information1;
    p3_a41 := ddx_rulv_rec.rule_information2;
    p3_a42 := ddx_rulv_rec.rule_information3;
    p3_a43 := ddx_rulv_rec.rule_information4;
    p3_a44 := ddx_rulv_rec.rule_information5;
    p3_a45 := ddx_rulv_rec.rule_information6;
    p3_a46 := ddx_rulv_rec.rule_information7;
    p3_a47 := ddx_rulv_rec.rule_information8;
    p3_a48 := ddx_rulv_rec.rule_information9;
    p3_a49 := ddx_rulv_rec.rule_information10;
    p3_a50 := ddx_rulv_rec.rule_information11;
    p3_a51 := ddx_rulv_rec.rule_information12;
    p3_a52 := ddx_rulv_rec.rule_information13;
    p3_a53 := ddx_rulv_rec.rule_information14;
    p3_a54 := ddx_rulv_rec.rule_information15;
    p3_a55 := ddx_rulv_rec.template_yn;
    p3_a56 := ddx_rulv_rec.ans_set_jtot_object_code;
    p3_a57 := ddx_rulv_rec.ans_set_jtot_object_id1;
    p3_a58 := ddx_rulv_rec.ans_set_jtot_object_id2;
    p3_a59 := rosetta_g_miss_num_map(ddx_rulv_rec.display_sequence);
  end;

  procedure insert_optvalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  DATE
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  DATE := fnd_api.g_miss_date
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  DATE := fnd_api.g_miss_date
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_optv_rec okl_setupoptvalues_pvt.optv_rec_type;
    ddp_ovev_rec okl_setupoptvalues_pvt.ovev_rec_type;
    ddx_ovev_rec okl_setupoptvalues_pvt.ovev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    ddp_ovev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_ovev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_ovev_rec.opt_id := rosetta_g_miss_num_map(p6_a2);
    ddp_ovev_rec.value := p6_a3;
    ddp_ovev_rec.description := p6_a4;
    ddp_ovev_rec.from_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_ovev_rec.to_date := rosetta_g_miss_date_in_map(p6_a6);
    ddp_ovev_rec.created_by := rosetta_g_miss_num_map(p6_a7);
    ddp_ovev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_ovev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a9);
    ddp_ovev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_ovev_rec.last_update_login := rosetta_g_miss_num_map(p6_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupoptvalues_pvt.insert_optvalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec,
      ddp_ovev_rec,
      ddx_ovev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_ovev_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_ovev_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_ovev_rec.opt_id);
    p7_a3 := ddx_ovev_rec.value;
    p7_a4 := ddx_ovev_rec.description;
    p7_a5 := ddx_ovev_rec.from_date;
    p7_a6 := ddx_ovev_rec.to_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_ovev_rec.created_by);
    p7_a8 := ddx_ovev_rec.creation_date;
    p7_a9 := rosetta_g_miss_num_map(ddx_ovev_rec.last_updated_by);
    p7_a10 := ddx_ovev_rec.last_update_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_ovev_rec.last_update_login);
  end;

  procedure update_optvalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  DATE
    , p7_a6 out nocopy  DATE
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  DATE
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  DATE
    , p7_a11 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  NUMBER := 0-1962.0724
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  NUMBER := 0-1962.0724
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  DATE := fnd_api.g_miss_date
    , p6_a6  DATE := fnd_api.g_miss_date
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  DATE := fnd_api.g_miss_date
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  NUMBER := 0-1962.0724
  )

  as
    ddp_optv_rec okl_setupoptvalues_pvt.optv_rec_type;
    ddp_ovev_rec okl_setupoptvalues_pvt.ovev_rec_type;
    ddx_ovev_rec okl_setupoptvalues_pvt.ovev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_optv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_optv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_optv_rec.name := p5_a2;
    ddp_optv_rec.description := p5_a3;
    ddp_optv_rec.from_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_optv_rec.to_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_optv_rec.attribute_category := p5_a6;
    ddp_optv_rec.attribute1 := p5_a7;
    ddp_optv_rec.attribute2 := p5_a8;
    ddp_optv_rec.attribute3 := p5_a9;
    ddp_optv_rec.attribute4 := p5_a10;
    ddp_optv_rec.attribute5 := p5_a11;
    ddp_optv_rec.attribute6 := p5_a12;
    ddp_optv_rec.attribute7 := p5_a13;
    ddp_optv_rec.attribute8 := p5_a14;
    ddp_optv_rec.attribute9 := p5_a15;
    ddp_optv_rec.attribute10 := p5_a16;
    ddp_optv_rec.attribute11 := p5_a17;
    ddp_optv_rec.attribute12 := p5_a18;
    ddp_optv_rec.attribute13 := p5_a19;
    ddp_optv_rec.attribute14 := p5_a20;
    ddp_optv_rec.attribute15 := p5_a21;
    ddp_optv_rec.created_by := rosetta_g_miss_num_map(p5_a22);
    ddp_optv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a23);
    ddp_optv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a24);
    ddp_optv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_optv_rec.last_update_login := rosetta_g_miss_num_map(p5_a26);

    ddp_ovev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_ovev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_ovev_rec.opt_id := rosetta_g_miss_num_map(p6_a2);
    ddp_ovev_rec.value := p6_a3;
    ddp_ovev_rec.description := p6_a4;
    ddp_ovev_rec.from_date := rosetta_g_miss_date_in_map(p6_a5);
    ddp_ovev_rec.to_date := rosetta_g_miss_date_in_map(p6_a6);
    ddp_ovev_rec.created_by := rosetta_g_miss_num_map(p6_a7);
    ddp_ovev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a8);
    ddp_ovev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a9);
    ddp_ovev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_ovev_rec.last_update_login := rosetta_g_miss_num_map(p6_a11);


    -- here's the delegated call to the old PL/SQL routine
    okl_setupoptvalues_pvt.update_optvalues(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_optv_rec,
      ddp_ovev_rec,
      ddx_ovev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_ovev_rec.id);
    p7_a1 := rosetta_g_miss_num_map(ddx_ovev_rec.object_version_number);
    p7_a2 := rosetta_g_miss_num_map(ddx_ovev_rec.opt_id);
    p7_a3 := ddx_ovev_rec.value;
    p7_a4 := ddx_ovev_rec.description;
    p7_a5 := ddx_ovev_rec.from_date;
    p7_a6 := ddx_ovev_rec.to_date;
    p7_a7 := rosetta_g_miss_num_map(ddx_ovev_rec.created_by);
    p7_a8 := ddx_ovev_rec.creation_date;
    p7_a9 := rosetta_g_miss_num_map(ddx_ovev_rec.last_updated_by);
    p7_a10 := ddx_ovev_rec.last_update_date;
    p7_a11 := rosetta_g_miss_num_map(ddx_ovev_rec.last_update_login);
  end;

end okl_setupoptvalues_pvt_w;

/
