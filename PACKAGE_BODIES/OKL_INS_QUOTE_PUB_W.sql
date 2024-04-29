--------------------------------------------------------
--  DDL for Package Body OKL_INS_QUOTE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INS_QUOTE_PUB_W" as
  /* $Header: OKLUINQB.pls 120.2 2005/09/19 11:37:31 pagarg noship $ */
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

  procedure save_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  VARCHAR2
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  DATE
    , p5_a20 in out nocopy  DATE
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  NUMBER
    , p5_a34 in out nocopy  NUMBER
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  VARCHAR2
    , p5_a40 in out nocopy  VARCHAR2
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  NUMBER
    , p5_a45 in out nocopy  NUMBER
    , p5_a46 in out nocopy  NUMBER
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , p5_a60 in out nocopy  VARCHAR2
    , p5_a61 in out nocopy  VARCHAR2
    , p5_a62 in out nocopy  VARCHAR2
    , p5_a63 in out nocopy  VARCHAR2
    , p5_a64 in out nocopy  NUMBER
    , p5_a65 in out nocopy  NUMBER
    , p5_a66 in out nocopy  DATE
    , p5_a67 in out nocopy  NUMBER
    , p5_a68 in out nocopy  NUMBER
    , p5_a69 in out nocopy  NUMBER
    , p5_a70 in out nocopy  NUMBER
    , p5_a71 in out nocopy  DATE
    , p5_a72 in out nocopy  NUMBER
    , p5_a73 in out nocopy  DATE
    , p5_a74 in out nocopy  NUMBER
    , p5_a75 in out nocopy  NUMBER
    , x_message out nocopy  VARCHAR2
  )

  as
    ddpx_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddpx_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddpx_ipyv_rec.ipy_type := p5_a1;
    ddpx_ipyv_rec.description := p5_a2;
    ddpx_ipyv_rec.endorsement := p5_a3;
    ddpx_ipyv_rec.sfwt_flag := p5_a4;
    ddpx_ipyv_rec.cancellation_comment := p5_a5;
    ddpx_ipyv_rec.comments := p5_a6;
    ddpx_ipyv_rec.name_of_insured := p5_a7;
    ddpx_ipyv_rec.policy_number := p5_a8;
    ddpx_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddpx_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddpx_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddpx_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddpx_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddpx_ipyv_rec.payment_frequency := p5_a14;
    ddpx_ipyv_rec.crx_code := p5_a15;
    ddpx_ipyv_rec.ipf_code := p5_a16;
    ddpx_ipyv_rec.iss_code := p5_a17;
    ddpx_ipyv_rec.ipe_code := p5_a18;
    ddpx_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddpx_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddpx_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddpx_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddpx_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddpx_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddpx_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddpx_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddpx_ipyv_rec.quote_yn := p5_a27;
    ddpx_ipyv_rec.on_file_yn := p5_a28;
    ddpx_ipyv_rec.private_label_yn := p5_a29;
    ddpx_ipyv_rec.agent_yn := p5_a30;
    ddpx_ipyv_rec.lessor_insured_yn := p5_a31;
    ddpx_ipyv_rec.lessor_payee_yn := p5_a32;
    ddpx_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddpx_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddpx_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddpx_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddpx_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddpx_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddpx_ipyv_rec.insurance_factor := p5_a39;
    ddpx_ipyv_rec.factor_code := p5_a40;
    ddpx_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddpx_ipyv_rec.agency_number := p5_a42;
    ddpx_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddpx_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddpx_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddpx_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddpx_ipyv_rec.territory_code := p5_a47;
    ddpx_ipyv_rec.attribute_category := p5_a48;
    ddpx_ipyv_rec.attribute1 := p5_a49;
    ddpx_ipyv_rec.attribute2 := p5_a50;
    ddpx_ipyv_rec.attribute3 := p5_a51;
    ddpx_ipyv_rec.attribute4 := p5_a52;
    ddpx_ipyv_rec.attribute5 := p5_a53;
    ddpx_ipyv_rec.attribute6 := p5_a54;
    ddpx_ipyv_rec.attribute7 := p5_a55;
    ddpx_ipyv_rec.attribute8 := p5_a56;
    ddpx_ipyv_rec.attribute9 := p5_a57;
    ddpx_ipyv_rec.attribute10 := p5_a58;
    ddpx_ipyv_rec.attribute11 := p5_a59;
    ddpx_ipyv_rec.attribute12 := p5_a60;
    ddpx_ipyv_rec.attribute13 := p5_a61;
    ddpx_ipyv_rec.attribute14 := p5_a62;
    ddpx_ipyv_rec.attribute15 := p5_a63;
    ddpx_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddpx_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddpx_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddpx_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddpx_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddpx_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddpx_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddpx_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddpx_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddpx_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddpx_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddpx_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);


    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pub.save_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddpx_ipyv_rec,
      x_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddpx_ipyv_rec.id);
    p5_a1 := ddpx_ipyv_rec.ipy_type;
    p5_a2 := ddpx_ipyv_rec.description;
    p5_a3 := ddpx_ipyv_rec.endorsement;
    p5_a4 := ddpx_ipyv_rec.sfwt_flag;
    p5_a5 := ddpx_ipyv_rec.cancellation_comment;
    p5_a6 := ddpx_ipyv_rec.comments;
    p5_a7 := ddpx_ipyv_rec.name_of_insured;
    p5_a8 := ddpx_ipyv_rec.policy_number;
    p5_a9 := rosetta_g_miss_num_map(ddpx_ipyv_rec.calculated_premium);
    p5_a10 := rosetta_g_miss_num_map(ddpx_ipyv_rec.premium);
    p5_a11 := rosetta_g_miss_num_map(ddpx_ipyv_rec.covered_amount);
    p5_a12 := rosetta_g_miss_num_map(ddpx_ipyv_rec.deductible);
    p5_a13 := rosetta_g_miss_num_map(ddpx_ipyv_rec.adjustment);
    p5_a14 := ddpx_ipyv_rec.payment_frequency;
    p5_a15 := ddpx_ipyv_rec.crx_code;
    p5_a16 := ddpx_ipyv_rec.ipf_code;
    p5_a17 := ddpx_ipyv_rec.iss_code;
    p5_a18 := ddpx_ipyv_rec.ipe_code;
    p5_a19 := ddpx_ipyv_rec.date_to;
    p5_a20 := ddpx_ipyv_rec.date_from;
    p5_a21 := ddpx_ipyv_rec.date_quoted;
    p5_a22 := ddpx_ipyv_rec.date_proof_provided;
    p5_a23 := ddpx_ipyv_rec.date_proof_required;
    p5_a24 := ddpx_ipyv_rec.cancellation_date;
    p5_a25 := ddpx_ipyv_rec.date_quote_expiry;
    p5_a26 := ddpx_ipyv_rec.activation_date;
    p5_a27 := ddpx_ipyv_rec.quote_yn;
    p5_a28 := ddpx_ipyv_rec.on_file_yn;
    p5_a29 := ddpx_ipyv_rec.private_label_yn;
    p5_a30 := ddpx_ipyv_rec.agent_yn;
    p5_a31 := ddpx_ipyv_rec.lessor_insured_yn;
    p5_a32 := ddpx_ipyv_rec.lessor_payee_yn;
    p5_a33 := rosetta_g_miss_num_map(ddpx_ipyv_rec.khr_id);
    p5_a34 := rosetta_g_miss_num_map(ddpx_ipyv_rec.kle_id);
    p5_a35 := rosetta_g_miss_num_map(ddpx_ipyv_rec.ipt_id);
    p5_a36 := rosetta_g_miss_num_map(ddpx_ipyv_rec.ipy_id);
    p5_a37 := rosetta_g_miss_num_map(ddpx_ipyv_rec.int_id);
    p5_a38 := rosetta_g_miss_num_map(ddpx_ipyv_rec.isu_id);
    p5_a39 := ddpx_ipyv_rec.insurance_factor;
    p5_a40 := ddpx_ipyv_rec.factor_code;
    p5_a41 := rosetta_g_miss_num_map(ddpx_ipyv_rec.factor_value);
    p5_a42 := ddpx_ipyv_rec.agency_number;
    p5_a43 := rosetta_g_miss_num_map(ddpx_ipyv_rec.agency_site_id);
    p5_a44 := rosetta_g_miss_num_map(ddpx_ipyv_rec.sales_rep_id);
    p5_a45 := rosetta_g_miss_num_map(ddpx_ipyv_rec.agent_site_id);
    p5_a46 := rosetta_g_miss_num_map(ddpx_ipyv_rec.adjusted_by_id);
    p5_a47 := ddpx_ipyv_rec.territory_code;
    p5_a48 := ddpx_ipyv_rec.attribute_category;
    p5_a49 := ddpx_ipyv_rec.attribute1;
    p5_a50 := ddpx_ipyv_rec.attribute2;
    p5_a51 := ddpx_ipyv_rec.attribute3;
    p5_a52 := ddpx_ipyv_rec.attribute4;
    p5_a53 := ddpx_ipyv_rec.attribute5;
    p5_a54 := ddpx_ipyv_rec.attribute6;
    p5_a55 := ddpx_ipyv_rec.attribute7;
    p5_a56 := ddpx_ipyv_rec.attribute8;
    p5_a57 := ddpx_ipyv_rec.attribute9;
    p5_a58 := ddpx_ipyv_rec.attribute10;
    p5_a59 := ddpx_ipyv_rec.attribute11;
    p5_a60 := ddpx_ipyv_rec.attribute12;
    p5_a61 := ddpx_ipyv_rec.attribute13;
    p5_a62 := ddpx_ipyv_rec.attribute14;
    p5_a63 := ddpx_ipyv_rec.attribute15;
    p5_a64 := rosetta_g_miss_num_map(ddpx_ipyv_rec.program_id);
    p5_a65 := rosetta_g_miss_num_map(ddpx_ipyv_rec.org_id);
    p5_a66 := ddpx_ipyv_rec.program_update_date;
    p5_a67 := rosetta_g_miss_num_map(ddpx_ipyv_rec.program_application_id);
    p5_a68 := rosetta_g_miss_num_map(ddpx_ipyv_rec.request_id);
    p5_a69 := rosetta_g_miss_num_map(ddpx_ipyv_rec.object_version_number);
    p5_a70 := rosetta_g_miss_num_map(ddpx_ipyv_rec.created_by);
    p5_a71 := ddpx_ipyv_rec.creation_date;
    p5_a72 := rosetta_g_miss_num_map(ddpx_ipyv_rec.last_updated_by);
    p5_a73 := ddpx_ipyv_rec.last_update_date;
    p5_a74 := rosetta_g_miss_num_map(ddpx_ipyv_rec.last_update_login);
    p5_a75 := rosetta_g_miss_num_map(ddpx_ipyv_rec.lease_application_id);

  end;

  procedure save_accept_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_message out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);


    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pub.save_accept_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec,
      x_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure create_ins_streams(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);

    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pub.create_ins_streams(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure calc_lease_premium(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  VARCHAR2
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  VARCHAR2
    , p5_a5 in out nocopy  VARCHAR2
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  VARCHAR2
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  VARCHAR2
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  DATE
    , p5_a20 in out nocopy  DATE
    , p5_a21 in out nocopy  DATE
    , p5_a22 in out nocopy  DATE
    , p5_a23 in out nocopy  DATE
    , p5_a24 in out nocopy  DATE
    , p5_a25 in out nocopy  DATE
    , p5_a26 in out nocopy  DATE
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  NUMBER
    , p5_a34 in out nocopy  NUMBER
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  VARCHAR2
    , p5_a40 in out nocopy  VARCHAR2
    , p5_a41 in out nocopy  NUMBER
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  NUMBER
    , p5_a44 in out nocopy  NUMBER
    , p5_a45 in out nocopy  NUMBER
    , p5_a46 in out nocopy  NUMBER
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  VARCHAR2
    , p5_a56 in out nocopy  VARCHAR2
    , p5_a57 in out nocopy  VARCHAR2
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , p5_a60 in out nocopy  VARCHAR2
    , p5_a61 in out nocopy  VARCHAR2
    , p5_a62 in out nocopy  VARCHAR2
    , p5_a63 in out nocopy  VARCHAR2
    , p5_a64 in out nocopy  NUMBER
    , p5_a65 in out nocopy  NUMBER
    , p5_a66 in out nocopy  DATE
    , p5_a67 in out nocopy  NUMBER
    , p5_a68 in out nocopy  NUMBER
    , p5_a69 in out nocopy  NUMBER
    , p5_a70 in out nocopy  NUMBER
    , p5_a71 in out nocopy  DATE
    , p5_a72 in out nocopy  NUMBER
    , p5_a73 in out nocopy  DATE
    , p5_a74 in out nocopy  NUMBER
    , p5_a75 in out nocopy  NUMBER
    , x_message out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddpx_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddx_iasset_tbl okl_ins_quote_pub.iasset_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddpx_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddpx_ipyv_rec.ipy_type := p5_a1;
    ddpx_ipyv_rec.description := p5_a2;
    ddpx_ipyv_rec.endorsement := p5_a3;
    ddpx_ipyv_rec.sfwt_flag := p5_a4;
    ddpx_ipyv_rec.cancellation_comment := p5_a5;
    ddpx_ipyv_rec.comments := p5_a6;
    ddpx_ipyv_rec.name_of_insured := p5_a7;
    ddpx_ipyv_rec.policy_number := p5_a8;
    ddpx_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddpx_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddpx_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddpx_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddpx_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddpx_ipyv_rec.payment_frequency := p5_a14;
    ddpx_ipyv_rec.crx_code := p5_a15;
    ddpx_ipyv_rec.ipf_code := p5_a16;
    ddpx_ipyv_rec.iss_code := p5_a17;
    ddpx_ipyv_rec.ipe_code := p5_a18;
    ddpx_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddpx_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddpx_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddpx_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddpx_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddpx_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddpx_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddpx_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddpx_ipyv_rec.quote_yn := p5_a27;
    ddpx_ipyv_rec.on_file_yn := p5_a28;
    ddpx_ipyv_rec.private_label_yn := p5_a29;
    ddpx_ipyv_rec.agent_yn := p5_a30;
    ddpx_ipyv_rec.lessor_insured_yn := p5_a31;
    ddpx_ipyv_rec.lessor_payee_yn := p5_a32;
    ddpx_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddpx_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddpx_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddpx_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddpx_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddpx_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddpx_ipyv_rec.insurance_factor := p5_a39;
    ddpx_ipyv_rec.factor_code := p5_a40;
    ddpx_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddpx_ipyv_rec.agency_number := p5_a42;
    ddpx_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddpx_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddpx_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddpx_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddpx_ipyv_rec.territory_code := p5_a47;
    ddpx_ipyv_rec.attribute_category := p5_a48;
    ddpx_ipyv_rec.attribute1 := p5_a49;
    ddpx_ipyv_rec.attribute2 := p5_a50;
    ddpx_ipyv_rec.attribute3 := p5_a51;
    ddpx_ipyv_rec.attribute4 := p5_a52;
    ddpx_ipyv_rec.attribute5 := p5_a53;
    ddpx_ipyv_rec.attribute6 := p5_a54;
    ddpx_ipyv_rec.attribute7 := p5_a55;
    ddpx_ipyv_rec.attribute8 := p5_a56;
    ddpx_ipyv_rec.attribute9 := p5_a57;
    ddpx_ipyv_rec.attribute10 := p5_a58;
    ddpx_ipyv_rec.attribute11 := p5_a59;
    ddpx_ipyv_rec.attribute12 := p5_a60;
    ddpx_ipyv_rec.attribute13 := p5_a61;
    ddpx_ipyv_rec.attribute14 := p5_a62;
    ddpx_ipyv_rec.attribute15 := p5_a63;
    ddpx_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddpx_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddpx_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddpx_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddpx_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddpx_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddpx_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddpx_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddpx_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddpx_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddpx_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddpx_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);



    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pub.calc_lease_premium(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddpx_ipyv_rec,
      x_message,
      ddx_iasset_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddpx_ipyv_rec.id);
    p5_a1 := ddpx_ipyv_rec.ipy_type;
    p5_a2 := ddpx_ipyv_rec.description;
    p5_a3 := ddpx_ipyv_rec.endorsement;
    p5_a4 := ddpx_ipyv_rec.sfwt_flag;
    p5_a5 := ddpx_ipyv_rec.cancellation_comment;
    p5_a6 := ddpx_ipyv_rec.comments;
    p5_a7 := ddpx_ipyv_rec.name_of_insured;
    p5_a8 := ddpx_ipyv_rec.policy_number;
    p5_a9 := rosetta_g_miss_num_map(ddpx_ipyv_rec.calculated_premium);
    p5_a10 := rosetta_g_miss_num_map(ddpx_ipyv_rec.premium);
    p5_a11 := rosetta_g_miss_num_map(ddpx_ipyv_rec.covered_amount);
    p5_a12 := rosetta_g_miss_num_map(ddpx_ipyv_rec.deductible);
    p5_a13 := rosetta_g_miss_num_map(ddpx_ipyv_rec.adjustment);
    p5_a14 := ddpx_ipyv_rec.payment_frequency;
    p5_a15 := ddpx_ipyv_rec.crx_code;
    p5_a16 := ddpx_ipyv_rec.ipf_code;
    p5_a17 := ddpx_ipyv_rec.iss_code;
    p5_a18 := ddpx_ipyv_rec.ipe_code;
    p5_a19 := ddpx_ipyv_rec.date_to;
    p5_a20 := ddpx_ipyv_rec.date_from;
    p5_a21 := ddpx_ipyv_rec.date_quoted;
    p5_a22 := ddpx_ipyv_rec.date_proof_provided;
    p5_a23 := ddpx_ipyv_rec.date_proof_required;
    p5_a24 := ddpx_ipyv_rec.cancellation_date;
    p5_a25 := ddpx_ipyv_rec.date_quote_expiry;
    p5_a26 := ddpx_ipyv_rec.activation_date;
    p5_a27 := ddpx_ipyv_rec.quote_yn;
    p5_a28 := ddpx_ipyv_rec.on_file_yn;
    p5_a29 := ddpx_ipyv_rec.private_label_yn;
    p5_a30 := ddpx_ipyv_rec.agent_yn;
    p5_a31 := ddpx_ipyv_rec.lessor_insured_yn;
    p5_a32 := ddpx_ipyv_rec.lessor_payee_yn;
    p5_a33 := rosetta_g_miss_num_map(ddpx_ipyv_rec.khr_id);
    p5_a34 := rosetta_g_miss_num_map(ddpx_ipyv_rec.kle_id);
    p5_a35 := rosetta_g_miss_num_map(ddpx_ipyv_rec.ipt_id);
    p5_a36 := rosetta_g_miss_num_map(ddpx_ipyv_rec.ipy_id);
    p5_a37 := rosetta_g_miss_num_map(ddpx_ipyv_rec.int_id);
    p5_a38 := rosetta_g_miss_num_map(ddpx_ipyv_rec.isu_id);
    p5_a39 := ddpx_ipyv_rec.insurance_factor;
    p5_a40 := ddpx_ipyv_rec.factor_code;
    p5_a41 := rosetta_g_miss_num_map(ddpx_ipyv_rec.factor_value);
    p5_a42 := ddpx_ipyv_rec.agency_number;
    p5_a43 := rosetta_g_miss_num_map(ddpx_ipyv_rec.agency_site_id);
    p5_a44 := rosetta_g_miss_num_map(ddpx_ipyv_rec.sales_rep_id);
    p5_a45 := rosetta_g_miss_num_map(ddpx_ipyv_rec.agent_site_id);
    p5_a46 := rosetta_g_miss_num_map(ddpx_ipyv_rec.adjusted_by_id);
    p5_a47 := ddpx_ipyv_rec.territory_code;
    p5_a48 := ddpx_ipyv_rec.attribute_category;
    p5_a49 := ddpx_ipyv_rec.attribute1;
    p5_a50 := ddpx_ipyv_rec.attribute2;
    p5_a51 := ddpx_ipyv_rec.attribute3;
    p5_a52 := ddpx_ipyv_rec.attribute4;
    p5_a53 := ddpx_ipyv_rec.attribute5;
    p5_a54 := ddpx_ipyv_rec.attribute6;
    p5_a55 := ddpx_ipyv_rec.attribute7;
    p5_a56 := ddpx_ipyv_rec.attribute8;
    p5_a57 := ddpx_ipyv_rec.attribute9;
    p5_a58 := ddpx_ipyv_rec.attribute10;
    p5_a59 := ddpx_ipyv_rec.attribute11;
    p5_a60 := ddpx_ipyv_rec.attribute12;
    p5_a61 := ddpx_ipyv_rec.attribute13;
    p5_a62 := ddpx_ipyv_rec.attribute14;
    p5_a63 := ddpx_ipyv_rec.attribute15;
    p5_a64 := rosetta_g_miss_num_map(ddpx_ipyv_rec.program_id);
    p5_a65 := rosetta_g_miss_num_map(ddpx_ipyv_rec.org_id);
    p5_a66 := ddpx_ipyv_rec.program_update_date;
    p5_a67 := rosetta_g_miss_num_map(ddpx_ipyv_rec.program_application_id);
    p5_a68 := rosetta_g_miss_num_map(ddpx_ipyv_rec.request_id);
    p5_a69 := rosetta_g_miss_num_map(ddpx_ipyv_rec.object_version_number);
    p5_a70 := rosetta_g_miss_num_map(ddpx_ipyv_rec.created_by);
    p5_a71 := ddpx_ipyv_rec.creation_date;
    p5_a72 := rosetta_g_miss_num_map(ddpx_ipyv_rec.last_updated_by);
    p5_a73 := ddpx_ipyv_rec.last_update_date;
    p5_a74 := rosetta_g_miss_num_map(ddpx_ipyv_rec.last_update_login);
    p5_a75 := rosetta_g_miss_num_map(ddpx_ipyv_rec.lease_application_id);


    okl_ins_quote_pvt_w.rosetta_table_copy_out_p5(ddx_iasset_tbl, p7_a0
      , p7_a1
      , p7_a2
      );
  end;

  procedure calc_optional_premium(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_message out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  NUMBER
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  DATE
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  DATE
    , p7_a22 out nocopy  DATE
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  DATE
    , p7_a25 out nocopy  DATE
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  NUMBER
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  NUMBER
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  NUMBER
    , p7_a42 out nocopy  VARCHAR2
    , p7_a43 out nocopy  NUMBER
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  NUMBER
    , p7_a46 out nocopy  NUMBER
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  VARCHAR2
    , p7_a50 out nocopy  VARCHAR2
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  VARCHAR2
    , p7_a55 out nocopy  VARCHAR2
    , p7_a56 out nocopy  VARCHAR2
    , p7_a57 out nocopy  VARCHAR2
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  VARCHAR2
    , p7_a62 out nocopy  VARCHAR2
    , p7_a63 out nocopy  VARCHAR2
    , p7_a64 out nocopy  NUMBER
    , p7_a65 out nocopy  NUMBER
    , p7_a66 out nocopy  DATE
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  NUMBER
    , p7_a69 out nocopy  NUMBER
    , p7_a70 out nocopy  NUMBER
    , p7_a71 out nocopy  DATE
    , p7_a72 out nocopy  NUMBER
    , p7_a73 out nocopy  DATE
    , p7_a74 out nocopy  NUMBER
    , p7_a75 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddx_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);



    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pub.calc_optional_premium(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec,
      x_message,
      ddx_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := rosetta_g_miss_num_map(ddx_ipyv_rec.id);
    p7_a1 := ddx_ipyv_rec.ipy_type;
    p7_a2 := ddx_ipyv_rec.description;
    p7_a3 := ddx_ipyv_rec.endorsement;
    p7_a4 := ddx_ipyv_rec.sfwt_flag;
    p7_a5 := ddx_ipyv_rec.cancellation_comment;
    p7_a6 := ddx_ipyv_rec.comments;
    p7_a7 := ddx_ipyv_rec.name_of_insured;
    p7_a8 := ddx_ipyv_rec.policy_number;
    p7_a9 := rosetta_g_miss_num_map(ddx_ipyv_rec.calculated_premium);
    p7_a10 := rosetta_g_miss_num_map(ddx_ipyv_rec.premium);
    p7_a11 := rosetta_g_miss_num_map(ddx_ipyv_rec.covered_amount);
    p7_a12 := rosetta_g_miss_num_map(ddx_ipyv_rec.deductible);
    p7_a13 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjustment);
    p7_a14 := ddx_ipyv_rec.payment_frequency;
    p7_a15 := ddx_ipyv_rec.crx_code;
    p7_a16 := ddx_ipyv_rec.ipf_code;
    p7_a17 := ddx_ipyv_rec.iss_code;
    p7_a18 := ddx_ipyv_rec.ipe_code;
    p7_a19 := ddx_ipyv_rec.date_to;
    p7_a20 := ddx_ipyv_rec.date_from;
    p7_a21 := ddx_ipyv_rec.date_quoted;
    p7_a22 := ddx_ipyv_rec.date_proof_provided;
    p7_a23 := ddx_ipyv_rec.date_proof_required;
    p7_a24 := ddx_ipyv_rec.cancellation_date;
    p7_a25 := ddx_ipyv_rec.date_quote_expiry;
    p7_a26 := ddx_ipyv_rec.activation_date;
    p7_a27 := ddx_ipyv_rec.quote_yn;
    p7_a28 := ddx_ipyv_rec.on_file_yn;
    p7_a29 := ddx_ipyv_rec.private_label_yn;
    p7_a30 := ddx_ipyv_rec.agent_yn;
    p7_a31 := ddx_ipyv_rec.lessor_insured_yn;
    p7_a32 := ddx_ipyv_rec.lessor_payee_yn;
    p7_a33 := rosetta_g_miss_num_map(ddx_ipyv_rec.khr_id);
    p7_a34 := rosetta_g_miss_num_map(ddx_ipyv_rec.kle_id);
    p7_a35 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipt_id);
    p7_a36 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipy_id);
    p7_a37 := rosetta_g_miss_num_map(ddx_ipyv_rec.int_id);
    p7_a38 := rosetta_g_miss_num_map(ddx_ipyv_rec.isu_id);
    p7_a39 := ddx_ipyv_rec.insurance_factor;
    p7_a40 := ddx_ipyv_rec.factor_code;
    p7_a41 := rosetta_g_miss_num_map(ddx_ipyv_rec.factor_value);
    p7_a42 := ddx_ipyv_rec.agency_number;
    p7_a43 := rosetta_g_miss_num_map(ddx_ipyv_rec.agency_site_id);
    p7_a44 := rosetta_g_miss_num_map(ddx_ipyv_rec.sales_rep_id);
    p7_a45 := rosetta_g_miss_num_map(ddx_ipyv_rec.agent_site_id);
    p7_a46 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjusted_by_id);
    p7_a47 := ddx_ipyv_rec.territory_code;
    p7_a48 := ddx_ipyv_rec.attribute_category;
    p7_a49 := ddx_ipyv_rec.attribute1;
    p7_a50 := ddx_ipyv_rec.attribute2;
    p7_a51 := ddx_ipyv_rec.attribute3;
    p7_a52 := ddx_ipyv_rec.attribute4;
    p7_a53 := ddx_ipyv_rec.attribute5;
    p7_a54 := ddx_ipyv_rec.attribute6;
    p7_a55 := ddx_ipyv_rec.attribute7;
    p7_a56 := ddx_ipyv_rec.attribute8;
    p7_a57 := ddx_ipyv_rec.attribute9;
    p7_a58 := ddx_ipyv_rec.attribute10;
    p7_a59 := ddx_ipyv_rec.attribute11;
    p7_a60 := ddx_ipyv_rec.attribute12;
    p7_a61 := ddx_ipyv_rec.attribute13;
    p7_a62 := ddx_ipyv_rec.attribute14;
    p7_a63 := ddx_ipyv_rec.attribute15;
    p7_a64 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_id);
    p7_a65 := rosetta_g_miss_num_map(ddx_ipyv_rec.org_id);
    p7_a66 := ddx_ipyv_rec.program_update_date;
    p7_a67 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_application_id);
    p7_a68 := rosetta_g_miss_num_map(ddx_ipyv_rec.request_id);
    p7_a69 := rosetta_g_miss_num_map(ddx_ipyv_rec.object_version_number);
    p7_a70 := rosetta_g_miss_num_map(ddx_ipyv_rec.created_by);
    p7_a71 := ddx_ipyv_rec.creation_date;
    p7_a72 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_updated_by);
    p7_a73 := ddx_ipyv_rec.last_update_date;
    p7_a74 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_update_login);
    p7_a75 := rosetta_g_miss_num_map(ddx_ipyv_rec.lease_application_id);
  end;

  procedure activate_ins_stream(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);

    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pub.activate_ins_stream(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_third_prt_ins(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  DATE
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  DATE
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddx_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);


    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pub.create_third_prt_ins(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec,
      ddx_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ipyv_rec.id);
    p6_a1 := ddx_ipyv_rec.ipy_type;
    p6_a2 := ddx_ipyv_rec.description;
    p6_a3 := ddx_ipyv_rec.endorsement;
    p6_a4 := ddx_ipyv_rec.sfwt_flag;
    p6_a5 := ddx_ipyv_rec.cancellation_comment;
    p6_a6 := ddx_ipyv_rec.comments;
    p6_a7 := ddx_ipyv_rec.name_of_insured;
    p6_a8 := ddx_ipyv_rec.policy_number;
    p6_a9 := rosetta_g_miss_num_map(ddx_ipyv_rec.calculated_premium);
    p6_a10 := rosetta_g_miss_num_map(ddx_ipyv_rec.premium);
    p6_a11 := rosetta_g_miss_num_map(ddx_ipyv_rec.covered_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_ipyv_rec.deductible);
    p6_a13 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjustment);
    p6_a14 := ddx_ipyv_rec.payment_frequency;
    p6_a15 := ddx_ipyv_rec.crx_code;
    p6_a16 := ddx_ipyv_rec.ipf_code;
    p6_a17 := ddx_ipyv_rec.iss_code;
    p6_a18 := ddx_ipyv_rec.ipe_code;
    p6_a19 := ddx_ipyv_rec.date_to;
    p6_a20 := ddx_ipyv_rec.date_from;
    p6_a21 := ddx_ipyv_rec.date_quoted;
    p6_a22 := ddx_ipyv_rec.date_proof_provided;
    p6_a23 := ddx_ipyv_rec.date_proof_required;
    p6_a24 := ddx_ipyv_rec.cancellation_date;
    p6_a25 := ddx_ipyv_rec.date_quote_expiry;
    p6_a26 := ddx_ipyv_rec.activation_date;
    p6_a27 := ddx_ipyv_rec.quote_yn;
    p6_a28 := ddx_ipyv_rec.on_file_yn;
    p6_a29 := ddx_ipyv_rec.private_label_yn;
    p6_a30 := ddx_ipyv_rec.agent_yn;
    p6_a31 := ddx_ipyv_rec.lessor_insured_yn;
    p6_a32 := ddx_ipyv_rec.lessor_payee_yn;
    p6_a33 := rosetta_g_miss_num_map(ddx_ipyv_rec.khr_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_ipyv_rec.kle_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipt_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipy_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_ipyv_rec.int_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_ipyv_rec.isu_id);
    p6_a39 := ddx_ipyv_rec.insurance_factor;
    p6_a40 := ddx_ipyv_rec.factor_code;
    p6_a41 := rosetta_g_miss_num_map(ddx_ipyv_rec.factor_value);
    p6_a42 := ddx_ipyv_rec.agency_number;
    p6_a43 := rosetta_g_miss_num_map(ddx_ipyv_rec.agency_site_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_ipyv_rec.sales_rep_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_ipyv_rec.agent_site_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjusted_by_id);
    p6_a47 := ddx_ipyv_rec.territory_code;
    p6_a48 := ddx_ipyv_rec.attribute_category;
    p6_a49 := ddx_ipyv_rec.attribute1;
    p6_a50 := ddx_ipyv_rec.attribute2;
    p6_a51 := ddx_ipyv_rec.attribute3;
    p6_a52 := ddx_ipyv_rec.attribute4;
    p6_a53 := ddx_ipyv_rec.attribute5;
    p6_a54 := ddx_ipyv_rec.attribute6;
    p6_a55 := ddx_ipyv_rec.attribute7;
    p6_a56 := ddx_ipyv_rec.attribute8;
    p6_a57 := ddx_ipyv_rec.attribute9;
    p6_a58 := ddx_ipyv_rec.attribute10;
    p6_a59 := ddx_ipyv_rec.attribute11;
    p6_a60 := ddx_ipyv_rec.attribute12;
    p6_a61 := ddx_ipyv_rec.attribute13;
    p6_a62 := ddx_ipyv_rec.attribute14;
    p6_a63 := ddx_ipyv_rec.attribute15;
    p6_a64 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_id);
    p6_a65 := rosetta_g_miss_num_map(ddx_ipyv_rec.org_id);
    p6_a66 := ddx_ipyv_rec.program_update_date;
    p6_a67 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_application_id);
    p6_a68 := rosetta_g_miss_num_map(ddx_ipyv_rec.request_id);
    p6_a69 := rosetta_g_miss_num_map(ddx_ipyv_rec.object_version_number);
    p6_a70 := rosetta_g_miss_num_map(ddx_ipyv_rec.created_by);
    p6_a71 := ddx_ipyv_rec.creation_date;
    p6_a72 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_updated_by);
    p6_a73 := ddx_ipyv_rec.last_update_date;
    p6_a74 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_update_login);
    p6_a75 := rosetta_g_miss_num_map(ddx_ipyv_rec.lease_application_id);
  end;

  procedure crt_lseapp_thrdprt_ins(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  DATE
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  DATE
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  DATE := fnd_api.g_miss_date
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  DATE := fnd_api.g_miss_date
    , p5_a25  DATE := fnd_api.g_miss_date
    , p5_a26  DATE := fnd_api.g_miss_date
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  NUMBER := 0-1962.0724
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  NUMBER := 0-1962.0724
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  NUMBER := 0-1962.0724
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  NUMBER := 0-1962.0724
    , p5_a65  NUMBER := 0-1962.0724
    , p5_a66  DATE := fnd_api.g_miss_date
    , p5_a67  NUMBER := 0-1962.0724
    , p5_a68  NUMBER := 0-1962.0724
    , p5_a69  NUMBER := 0-1962.0724
    , p5_a70  NUMBER := 0-1962.0724
    , p5_a71  DATE := fnd_api.g_miss_date
    , p5_a72  NUMBER := 0-1962.0724
    , p5_a73  DATE := fnd_api.g_miss_date
    , p5_a74  NUMBER := 0-1962.0724
    , p5_a75  NUMBER := 0-1962.0724
  )

  as
    ddp_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddx_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ipyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_ipyv_rec.ipy_type := p5_a1;
    ddp_ipyv_rec.description := p5_a2;
    ddp_ipyv_rec.endorsement := p5_a3;
    ddp_ipyv_rec.sfwt_flag := p5_a4;
    ddp_ipyv_rec.cancellation_comment := p5_a5;
    ddp_ipyv_rec.comments := p5_a6;
    ddp_ipyv_rec.name_of_insured := p5_a7;
    ddp_ipyv_rec.policy_number := p5_a8;
    ddp_ipyv_rec.calculated_premium := rosetta_g_miss_num_map(p5_a9);
    ddp_ipyv_rec.premium := rosetta_g_miss_num_map(p5_a10);
    ddp_ipyv_rec.covered_amount := rosetta_g_miss_num_map(p5_a11);
    ddp_ipyv_rec.deductible := rosetta_g_miss_num_map(p5_a12);
    ddp_ipyv_rec.adjustment := rosetta_g_miss_num_map(p5_a13);
    ddp_ipyv_rec.payment_frequency := p5_a14;
    ddp_ipyv_rec.crx_code := p5_a15;
    ddp_ipyv_rec.ipf_code := p5_a16;
    ddp_ipyv_rec.iss_code := p5_a17;
    ddp_ipyv_rec.ipe_code := p5_a18;
    ddp_ipyv_rec.date_to := rosetta_g_miss_date_in_map(p5_a19);
    ddp_ipyv_rec.date_from := rosetta_g_miss_date_in_map(p5_a20);
    ddp_ipyv_rec.date_quoted := rosetta_g_miss_date_in_map(p5_a21);
    ddp_ipyv_rec.date_proof_provided := rosetta_g_miss_date_in_map(p5_a22);
    ddp_ipyv_rec.date_proof_required := rosetta_g_miss_date_in_map(p5_a23);
    ddp_ipyv_rec.cancellation_date := rosetta_g_miss_date_in_map(p5_a24);
    ddp_ipyv_rec.date_quote_expiry := rosetta_g_miss_date_in_map(p5_a25);
    ddp_ipyv_rec.activation_date := rosetta_g_miss_date_in_map(p5_a26);
    ddp_ipyv_rec.quote_yn := p5_a27;
    ddp_ipyv_rec.on_file_yn := p5_a28;
    ddp_ipyv_rec.private_label_yn := p5_a29;
    ddp_ipyv_rec.agent_yn := p5_a30;
    ddp_ipyv_rec.lessor_insured_yn := p5_a31;
    ddp_ipyv_rec.lessor_payee_yn := p5_a32;
    ddp_ipyv_rec.khr_id := rosetta_g_miss_num_map(p5_a33);
    ddp_ipyv_rec.kle_id := rosetta_g_miss_num_map(p5_a34);
    ddp_ipyv_rec.ipt_id := rosetta_g_miss_num_map(p5_a35);
    ddp_ipyv_rec.ipy_id := rosetta_g_miss_num_map(p5_a36);
    ddp_ipyv_rec.int_id := rosetta_g_miss_num_map(p5_a37);
    ddp_ipyv_rec.isu_id := rosetta_g_miss_num_map(p5_a38);
    ddp_ipyv_rec.insurance_factor := p5_a39;
    ddp_ipyv_rec.factor_code := p5_a40;
    ddp_ipyv_rec.factor_value := rosetta_g_miss_num_map(p5_a41);
    ddp_ipyv_rec.agency_number := p5_a42;
    ddp_ipyv_rec.agency_site_id := rosetta_g_miss_num_map(p5_a43);
    ddp_ipyv_rec.sales_rep_id := rosetta_g_miss_num_map(p5_a44);
    ddp_ipyv_rec.agent_site_id := rosetta_g_miss_num_map(p5_a45);
    ddp_ipyv_rec.adjusted_by_id := rosetta_g_miss_num_map(p5_a46);
    ddp_ipyv_rec.territory_code := p5_a47;
    ddp_ipyv_rec.attribute_category := p5_a48;
    ddp_ipyv_rec.attribute1 := p5_a49;
    ddp_ipyv_rec.attribute2 := p5_a50;
    ddp_ipyv_rec.attribute3 := p5_a51;
    ddp_ipyv_rec.attribute4 := p5_a52;
    ddp_ipyv_rec.attribute5 := p5_a53;
    ddp_ipyv_rec.attribute6 := p5_a54;
    ddp_ipyv_rec.attribute7 := p5_a55;
    ddp_ipyv_rec.attribute8 := p5_a56;
    ddp_ipyv_rec.attribute9 := p5_a57;
    ddp_ipyv_rec.attribute10 := p5_a58;
    ddp_ipyv_rec.attribute11 := p5_a59;
    ddp_ipyv_rec.attribute12 := p5_a60;
    ddp_ipyv_rec.attribute13 := p5_a61;
    ddp_ipyv_rec.attribute14 := p5_a62;
    ddp_ipyv_rec.attribute15 := p5_a63;
    ddp_ipyv_rec.program_id := rosetta_g_miss_num_map(p5_a64);
    ddp_ipyv_rec.org_id := rosetta_g_miss_num_map(p5_a65);
    ddp_ipyv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a66);
    ddp_ipyv_rec.program_application_id := rosetta_g_miss_num_map(p5_a67);
    ddp_ipyv_rec.request_id := rosetta_g_miss_num_map(p5_a68);
    ddp_ipyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a69);
    ddp_ipyv_rec.created_by := rosetta_g_miss_num_map(p5_a70);
    ddp_ipyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a71);
    ddp_ipyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a72);
    ddp_ipyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a73);
    ddp_ipyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a74);
    ddp_ipyv_rec.lease_application_id := rosetta_g_miss_num_map(p5_a75);


    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pub.crt_lseapp_thrdprt_ins(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ipyv_rec,
      ddx_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ipyv_rec.id);
    p6_a1 := ddx_ipyv_rec.ipy_type;
    p6_a2 := ddx_ipyv_rec.description;
    p6_a3 := ddx_ipyv_rec.endorsement;
    p6_a4 := ddx_ipyv_rec.sfwt_flag;
    p6_a5 := ddx_ipyv_rec.cancellation_comment;
    p6_a6 := ddx_ipyv_rec.comments;
    p6_a7 := ddx_ipyv_rec.name_of_insured;
    p6_a8 := ddx_ipyv_rec.policy_number;
    p6_a9 := rosetta_g_miss_num_map(ddx_ipyv_rec.calculated_premium);
    p6_a10 := rosetta_g_miss_num_map(ddx_ipyv_rec.premium);
    p6_a11 := rosetta_g_miss_num_map(ddx_ipyv_rec.covered_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_ipyv_rec.deductible);
    p6_a13 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjustment);
    p6_a14 := ddx_ipyv_rec.payment_frequency;
    p6_a15 := ddx_ipyv_rec.crx_code;
    p6_a16 := ddx_ipyv_rec.ipf_code;
    p6_a17 := ddx_ipyv_rec.iss_code;
    p6_a18 := ddx_ipyv_rec.ipe_code;
    p6_a19 := ddx_ipyv_rec.date_to;
    p6_a20 := ddx_ipyv_rec.date_from;
    p6_a21 := ddx_ipyv_rec.date_quoted;
    p6_a22 := ddx_ipyv_rec.date_proof_provided;
    p6_a23 := ddx_ipyv_rec.date_proof_required;
    p6_a24 := ddx_ipyv_rec.cancellation_date;
    p6_a25 := ddx_ipyv_rec.date_quote_expiry;
    p6_a26 := ddx_ipyv_rec.activation_date;
    p6_a27 := ddx_ipyv_rec.quote_yn;
    p6_a28 := ddx_ipyv_rec.on_file_yn;
    p6_a29 := ddx_ipyv_rec.private_label_yn;
    p6_a30 := ddx_ipyv_rec.agent_yn;
    p6_a31 := ddx_ipyv_rec.lessor_insured_yn;
    p6_a32 := ddx_ipyv_rec.lessor_payee_yn;
    p6_a33 := rosetta_g_miss_num_map(ddx_ipyv_rec.khr_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_ipyv_rec.kle_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipt_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipy_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_ipyv_rec.int_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_ipyv_rec.isu_id);
    p6_a39 := ddx_ipyv_rec.insurance_factor;
    p6_a40 := ddx_ipyv_rec.factor_code;
    p6_a41 := rosetta_g_miss_num_map(ddx_ipyv_rec.factor_value);
    p6_a42 := ddx_ipyv_rec.agency_number;
    p6_a43 := rosetta_g_miss_num_map(ddx_ipyv_rec.agency_site_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_ipyv_rec.sales_rep_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_ipyv_rec.agent_site_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjusted_by_id);
    p6_a47 := ddx_ipyv_rec.territory_code;
    p6_a48 := ddx_ipyv_rec.attribute_category;
    p6_a49 := ddx_ipyv_rec.attribute1;
    p6_a50 := ddx_ipyv_rec.attribute2;
    p6_a51 := ddx_ipyv_rec.attribute3;
    p6_a52 := ddx_ipyv_rec.attribute4;
    p6_a53 := ddx_ipyv_rec.attribute5;
    p6_a54 := ddx_ipyv_rec.attribute6;
    p6_a55 := ddx_ipyv_rec.attribute7;
    p6_a56 := ddx_ipyv_rec.attribute8;
    p6_a57 := ddx_ipyv_rec.attribute9;
    p6_a58 := ddx_ipyv_rec.attribute10;
    p6_a59 := ddx_ipyv_rec.attribute11;
    p6_a60 := ddx_ipyv_rec.attribute12;
    p6_a61 := ddx_ipyv_rec.attribute13;
    p6_a62 := ddx_ipyv_rec.attribute14;
    p6_a63 := ddx_ipyv_rec.attribute15;
    p6_a64 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_id);
    p6_a65 := rosetta_g_miss_num_map(ddx_ipyv_rec.org_id);
    p6_a66 := ddx_ipyv_rec.program_update_date;
    p6_a67 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_application_id);
    p6_a68 := rosetta_g_miss_num_map(ddx_ipyv_rec.request_id);
    p6_a69 := rosetta_g_miss_num_map(ddx_ipyv_rec.object_version_number);
    p6_a70 := rosetta_g_miss_num_map(ddx_ipyv_rec.created_by);
    p6_a71 := ddx_ipyv_rec.creation_date;
    p6_a72 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_updated_by);
    p6_a73 := ddx_ipyv_rec.last_update_date;
    p6_a74 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_update_login);
    p6_a75 := rosetta_g_miss_num_map(ddx_ipyv_rec.lease_application_id);
  end;

  procedure lseapp_thrdprty_to_ctrct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lakhr_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  DATE
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  VARCHAR2
    , p6_a56 out nocopy  VARCHAR2
    , p6_a57 out nocopy  VARCHAR2
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  VARCHAR2
    , p6_a64 out nocopy  NUMBER
    , p6_a65 out nocopy  NUMBER
    , p6_a66 out nocopy  DATE
    , p6_a67 out nocopy  NUMBER
    , p6_a68 out nocopy  NUMBER
    , p6_a69 out nocopy  NUMBER
    , p6_a70 out nocopy  NUMBER
    , p6_a71 out nocopy  DATE
    , p6_a72 out nocopy  NUMBER
    , p6_a73 out nocopy  DATE
    , p6_a74 out nocopy  NUMBER
    , p6_a75 out nocopy  NUMBER
  )

  as
    ddx_ipyv_rec okl_ins_quote_pub.ipyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_ins_quote_pub.lseapp_thrdprty_to_ctrct(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_lakhr_id,
      ddx_ipyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_ipyv_rec.id);
    p6_a1 := ddx_ipyv_rec.ipy_type;
    p6_a2 := ddx_ipyv_rec.description;
    p6_a3 := ddx_ipyv_rec.endorsement;
    p6_a4 := ddx_ipyv_rec.sfwt_flag;
    p6_a5 := ddx_ipyv_rec.cancellation_comment;
    p6_a6 := ddx_ipyv_rec.comments;
    p6_a7 := ddx_ipyv_rec.name_of_insured;
    p6_a8 := ddx_ipyv_rec.policy_number;
    p6_a9 := rosetta_g_miss_num_map(ddx_ipyv_rec.calculated_premium);
    p6_a10 := rosetta_g_miss_num_map(ddx_ipyv_rec.premium);
    p6_a11 := rosetta_g_miss_num_map(ddx_ipyv_rec.covered_amount);
    p6_a12 := rosetta_g_miss_num_map(ddx_ipyv_rec.deductible);
    p6_a13 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjustment);
    p6_a14 := ddx_ipyv_rec.payment_frequency;
    p6_a15 := ddx_ipyv_rec.crx_code;
    p6_a16 := ddx_ipyv_rec.ipf_code;
    p6_a17 := ddx_ipyv_rec.iss_code;
    p6_a18 := ddx_ipyv_rec.ipe_code;
    p6_a19 := ddx_ipyv_rec.date_to;
    p6_a20 := ddx_ipyv_rec.date_from;
    p6_a21 := ddx_ipyv_rec.date_quoted;
    p6_a22 := ddx_ipyv_rec.date_proof_provided;
    p6_a23 := ddx_ipyv_rec.date_proof_required;
    p6_a24 := ddx_ipyv_rec.cancellation_date;
    p6_a25 := ddx_ipyv_rec.date_quote_expiry;
    p6_a26 := ddx_ipyv_rec.activation_date;
    p6_a27 := ddx_ipyv_rec.quote_yn;
    p6_a28 := ddx_ipyv_rec.on_file_yn;
    p6_a29 := ddx_ipyv_rec.private_label_yn;
    p6_a30 := ddx_ipyv_rec.agent_yn;
    p6_a31 := ddx_ipyv_rec.lessor_insured_yn;
    p6_a32 := ddx_ipyv_rec.lessor_payee_yn;
    p6_a33 := rosetta_g_miss_num_map(ddx_ipyv_rec.khr_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_ipyv_rec.kle_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipt_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_ipyv_rec.ipy_id);
    p6_a37 := rosetta_g_miss_num_map(ddx_ipyv_rec.int_id);
    p6_a38 := rosetta_g_miss_num_map(ddx_ipyv_rec.isu_id);
    p6_a39 := ddx_ipyv_rec.insurance_factor;
    p6_a40 := ddx_ipyv_rec.factor_code;
    p6_a41 := rosetta_g_miss_num_map(ddx_ipyv_rec.factor_value);
    p6_a42 := ddx_ipyv_rec.agency_number;
    p6_a43 := rosetta_g_miss_num_map(ddx_ipyv_rec.agency_site_id);
    p6_a44 := rosetta_g_miss_num_map(ddx_ipyv_rec.sales_rep_id);
    p6_a45 := rosetta_g_miss_num_map(ddx_ipyv_rec.agent_site_id);
    p6_a46 := rosetta_g_miss_num_map(ddx_ipyv_rec.adjusted_by_id);
    p6_a47 := ddx_ipyv_rec.territory_code;
    p6_a48 := ddx_ipyv_rec.attribute_category;
    p6_a49 := ddx_ipyv_rec.attribute1;
    p6_a50 := ddx_ipyv_rec.attribute2;
    p6_a51 := ddx_ipyv_rec.attribute3;
    p6_a52 := ddx_ipyv_rec.attribute4;
    p6_a53 := ddx_ipyv_rec.attribute5;
    p6_a54 := ddx_ipyv_rec.attribute6;
    p6_a55 := ddx_ipyv_rec.attribute7;
    p6_a56 := ddx_ipyv_rec.attribute8;
    p6_a57 := ddx_ipyv_rec.attribute9;
    p6_a58 := ddx_ipyv_rec.attribute10;
    p6_a59 := ddx_ipyv_rec.attribute11;
    p6_a60 := ddx_ipyv_rec.attribute12;
    p6_a61 := ddx_ipyv_rec.attribute13;
    p6_a62 := ddx_ipyv_rec.attribute14;
    p6_a63 := ddx_ipyv_rec.attribute15;
    p6_a64 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_id);
    p6_a65 := rosetta_g_miss_num_map(ddx_ipyv_rec.org_id);
    p6_a66 := ddx_ipyv_rec.program_update_date;
    p6_a67 := rosetta_g_miss_num_map(ddx_ipyv_rec.program_application_id);
    p6_a68 := rosetta_g_miss_num_map(ddx_ipyv_rec.request_id);
    p6_a69 := rosetta_g_miss_num_map(ddx_ipyv_rec.object_version_number);
    p6_a70 := rosetta_g_miss_num_map(ddx_ipyv_rec.created_by);
    p6_a71 := ddx_ipyv_rec.creation_date;
    p6_a72 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_updated_by);
    p6_a73 := ddx_ipyv_rec.last_update_date;
    p6_a74 := rosetta_g_miss_num_map(ddx_ipyv_rec.last_update_login);
    p6_a75 := rosetta_g_miss_num_map(ddx_ipyv_rec.lease_application_id);
  end;

end okl_ins_quote_pub_w;

/
