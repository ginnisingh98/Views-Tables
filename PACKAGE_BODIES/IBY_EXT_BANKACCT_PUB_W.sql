--------------------------------------------------------
--  DDL for Package Body IBY_EXT_BANKACCT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_EXT_BANKACCT_PUB_W" as
  /* $Header: ibyxbnkwb.pls 120.4.12010000.5 2010/02/26 06:01:20 svinjamu ship $ */
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

  procedure create_ext_bank(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , x_bank_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  )

  as
    ddp_ext_bank_rec iby_ext_bankacct_pub.extbank_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_ext_bank_rec.bank_id := p2_a0;
    ddp_ext_bank_rec.bank_name := p2_a1;
    ddp_ext_bank_rec.bank_number := p2_a2;
    ddp_ext_bank_rec.institution_type := p2_a3;
    ddp_ext_bank_rec.country_code := p2_a4;
    ddp_ext_bank_rec.bank_alt_name := p2_a5;
    ddp_ext_bank_rec.bank_short_name := p2_a6;
    ddp_ext_bank_rec.description := p2_a7;
    ddp_ext_bank_rec.tax_payer_id := p2_a8;
    ddp_ext_bank_rec.tax_registration_number := p2_a9;
    ddp_ext_bank_rec.attribute_category := p2_a10;
    ddp_ext_bank_rec.attribute1 := p2_a11;
    ddp_ext_bank_rec.attribute2 := p2_a12;
    ddp_ext_bank_rec.attribute3 := p2_a13;
    ddp_ext_bank_rec.attribute4 := p2_a14;
    ddp_ext_bank_rec.attribute5 := p2_a15;
    ddp_ext_bank_rec.attribute6 := p2_a16;
    ddp_ext_bank_rec.attribute7 := p2_a17;
    ddp_ext_bank_rec.attribute8 := p2_a18;
    ddp_ext_bank_rec.attribute9 := p2_a19;
    ddp_ext_bank_rec.attribute10 := p2_a20;
    ddp_ext_bank_rec.attribute11 := p2_a21;
    ddp_ext_bank_rec.attribute12 := p2_a22;
    ddp_ext_bank_rec.attribute13 := p2_a23;
    ddp_ext_bank_rec.attribute14 := p2_a24;
    ddp_ext_bank_rec.attribute15 := p2_a25;
    ddp_ext_bank_rec.attribute16 := p2_a26;
    ddp_ext_bank_rec.attribute17 := p2_a27;
    ddp_ext_bank_rec.attribute18 := p2_a28;
    ddp_ext_bank_rec.attribute19 := p2_a29;
    ddp_ext_bank_rec.attribute20 := p2_a30;
    ddp_ext_bank_rec.attribute21 := p2_a31;
    ddp_ext_bank_rec.attribute22 := p2_a32;
    ddp_ext_bank_rec.attribute23 := p2_a33;
    ddp_ext_bank_rec.attribute24 := p2_a34;
    ddp_ext_bank_rec.object_version_number := p2_a35;






    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.create_ext_bank(p_api_version,
      p_init_msg_list,
      ddp_ext_bank_rec,
      x_bank_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_response.result_code;
    p7_a1 := ddx_response.result_category;
    p7_a2 := ddx_response.result_message;
  end;

  procedure update_ext_bank(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
  )

  as
    ddp_ext_bank_rec iby_ext_bankacct_pub.extbank_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_ext_bank_rec.bank_id := p2_a0;
    ddp_ext_bank_rec.bank_name := p2_a1;
    ddp_ext_bank_rec.bank_number := p2_a2;
    ddp_ext_bank_rec.institution_type := p2_a3;
    ddp_ext_bank_rec.country_code := p2_a4;
    ddp_ext_bank_rec.bank_alt_name := p2_a5;
    ddp_ext_bank_rec.bank_short_name := p2_a6;
    ddp_ext_bank_rec.description := p2_a7;
    ddp_ext_bank_rec.tax_payer_id := p2_a8;
    ddp_ext_bank_rec.tax_registration_number := p2_a9;
    ddp_ext_bank_rec.attribute_category := p2_a10;
    ddp_ext_bank_rec.attribute1 := p2_a11;
    ddp_ext_bank_rec.attribute2 := p2_a12;
    ddp_ext_bank_rec.attribute3 := p2_a13;
    ddp_ext_bank_rec.attribute4 := p2_a14;
    ddp_ext_bank_rec.attribute5 := p2_a15;
    ddp_ext_bank_rec.attribute6 := p2_a16;
    ddp_ext_bank_rec.attribute7 := p2_a17;
    ddp_ext_bank_rec.attribute8 := p2_a18;
    ddp_ext_bank_rec.attribute9 := p2_a19;
    ddp_ext_bank_rec.attribute10 := p2_a20;
    ddp_ext_bank_rec.attribute11 := p2_a21;
    ddp_ext_bank_rec.attribute12 := p2_a22;
    ddp_ext_bank_rec.attribute13 := p2_a23;
    ddp_ext_bank_rec.attribute14 := p2_a24;
    ddp_ext_bank_rec.attribute15 := p2_a25;
    ddp_ext_bank_rec.attribute16 := p2_a26;
    ddp_ext_bank_rec.attribute17 := p2_a27;
    ddp_ext_bank_rec.attribute18 := p2_a28;
    ddp_ext_bank_rec.attribute19 := p2_a29;
    ddp_ext_bank_rec.attribute20 := p2_a30;
    ddp_ext_bank_rec.attribute21 := p2_a31;
    ddp_ext_bank_rec.attribute22 := p2_a32;
    ddp_ext_bank_rec.attribute23 := p2_a33;
    ddp_ext_bank_rec.attribute24 := p2_a34;
    ddp_ext_bank_rec.object_version_number := p2_a35;





    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.update_ext_bank(p_api_version,
      p_init_msg_list,
      ddp_ext_bank_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_response.result_code;
    p6_a1 := ddx_response.result_category;
    p6_a2 := ddx_response.result_message;
  end;

  procedure set_bank_end_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_id  NUMBER
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  )

  as
    ddp_end_date date;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);





    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.set_bank_end_date(p_api_version,
      p_init_msg_list,
      p_bank_id,
      ddp_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_response.result_code;
    p7_a1 := ddx_response.result_category;
    p7_a2 := ddx_response.result_message;
  end;

  procedure check_bank_exist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_country_code  VARCHAR2
    , p_bank_name  VARCHAR2
    , p_bank_number  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_bank_id out nocopy  NUMBER
    , x_end_date out nocopy  DATE
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
  )

  as
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.check_bank_exist(p_api_version,
      p_init_msg_list,
      p_country_code,
      p_bank_name,
      p_bank_number,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_bank_id,
      x_end_date,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := ddx_response.result_code;
    p10_a1 := ddx_response.result_category;
    p10_a2 := ddx_response.result_message;
  end;

  procedure create_ext_bank_branch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  NUMBER
    , p2_a36  NUMBER
    , p2_a37  NUMBER
    , p2_a38  NUMBER
    , x_branch_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  )

  as
    ddp_ext_bank_branch_rec iby_ext_bankacct_pub.extbankbranch_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_ext_bank_branch_rec.branch_party_id := p2_a0;
    ddp_ext_bank_branch_rec.bank_party_id := p2_a1;
    ddp_ext_bank_branch_rec.branch_name := p2_a2;
    ddp_ext_bank_branch_rec.branch_number := p2_a3;
    ddp_ext_bank_branch_rec.branch_type := p2_a4;
    ddp_ext_bank_branch_rec.alternate_branch_name := p2_a5;
    ddp_ext_bank_branch_rec.description := p2_a6;
    ddp_ext_bank_branch_rec.bic := p2_a7;
    ddp_ext_bank_branch_rec.eft_number := p2_a8;
    ddp_ext_bank_branch_rec.rfc_identifier := p2_a9;
    ddp_ext_bank_branch_rec.attribute_category := p2_a10;
    ddp_ext_bank_branch_rec.attribute1 := p2_a11;
    ddp_ext_bank_branch_rec.attribute2 := p2_a12;
    ddp_ext_bank_branch_rec.attribute3 := p2_a13;
    ddp_ext_bank_branch_rec.attribute4 := p2_a14;
    ddp_ext_bank_branch_rec.attribute5 := p2_a15;
    ddp_ext_bank_branch_rec.attribute6 := p2_a16;
    ddp_ext_bank_branch_rec.attribute7 := p2_a17;
    ddp_ext_bank_branch_rec.attribute8 := p2_a18;
    ddp_ext_bank_branch_rec.attribute9 := p2_a19;
    ddp_ext_bank_branch_rec.attribute10 := p2_a20;
    ddp_ext_bank_branch_rec.attribute11 := p2_a21;
    ddp_ext_bank_branch_rec.attribute12 := p2_a22;
    ddp_ext_bank_branch_rec.attribute13 := p2_a23;
    ddp_ext_bank_branch_rec.attribute14 := p2_a24;
    ddp_ext_bank_branch_rec.attribute15 := p2_a25;
    ddp_ext_bank_branch_rec.attribute16 := p2_a26;
    ddp_ext_bank_branch_rec.attribute17 := p2_a27;
    ddp_ext_bank_branch_rec.attribute18 := p2_a28;
    ddp_ext_bank_branch_rec.attribute19 := p2_a29;
    ddp_ext_bank_branch_rec.attribute20 := p2_a30;
    ddp_ext_bank_branch_rec.attribute21 := p2_a31;
    ddp_ext_bank_branch_rec.attribute22 := p2_a32;
    ddp_ext_bank_branch_rec.attribute23 := p2_a33;
    ddp_ext_bank_branch_rec.attribute24 := p2_a34;
    ddp_ext_bank_branch_rec.bch_object_version_number := p2_a35;
    ddp_ext_bank_branch_rec.typ_object_version_number := p2_a36;
    ddp_ext_bank_branch_rec.rfc_object_version_number := p2_a37;
    ddp_ext_bank_branch_rec.eft_object_version_number := p2_a38;






    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.create_ext_bank_branch(p_api_version,
      p_init_msg_list,
      ddp_ext_bank_branch_rec,
      x_branch_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_response.result_code;
    p7_a1 := ddx_response.result_category;
    p7_a2 := ddx_response.result_message;
  end;

  procedure update_ext_bank_branch(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 in out nocopy  NUMBER
    , p2_a1 in out nocopy  NUMBER
    , p2_a2 in out nocopy  VARCHAR2
    , p2_a3 in out nocopy  VARCHAR2
    , p2_a4 in out nocopy  VARCHAR2
    , p2_a5 in out nocopy  VARCHAR2
    , p2_a6 in out nocopy  VARCHAR2
    , p2_a7 in out nocopy  VARCHAR2
    , p2_a8 in out nocopy  VARCHAR2
    , p2_a9 in out nocopy  VARCHAR2
    , p2_a10 in out nocopy  VARCHAR2
    , p2_a11 in out nocopy  VARCHAR2
    , p2_a12 in out nocopy  VARCHAR2
    , p2_a13 in out nocopy  VARCHAR2
    , p2_a14 in out nocopy  VARCHAR2
    , p2_a15 in out nocopy  VARCHAR2
    , p2_a16 in out nocopy  VARCHAR2
    , p2_a17 in out nocopy  VARCHAR2
    , p2_a18 in out nocopy  VARCHAR2
    , p2_a19 in out nocopy  VARCHAR2
    , p2_a20 in out nocopy  VARCHAR2
    , p2_a21 in out nocopy  VARCHAR2
    , p2_a22 in out nocopy  VARCHAR2
    , p2_a23 in out nocopy  VARCHAR2
    , p2_a24 in out nocopy  VARCHAR2
    , p2_a25 in out nocopy  VARCHAR2
    , p2_a26 in out nocopy  VARCHAR2
    , p2_a27 in out nocopy  VARCHAR2
    , p2_a28 in out nocopy  VARCHAR2
    , p2_a29 in out nocopy  VARCHAR2
    , p2_a30 in out nocopy  VARCHAR2
    , p2_a31 in out nocopy  VARCHAR2
    , p2_a32 in out nocopy  VARCHAR2
    , p2_a33 in out nocopy  VARCHAR2
    , p2_a34 in out nocopy  VARCHAR2
    , p2_a35 in out nocopy  NUMBER
    , p2_a36 in out nocopy  NUMBER
    , p2_a37 in out nocopy  NUMBER
    , p2_a38 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
  )

  as
    ddp_ext_bank_branch_rec iby_ext_bankacct_pub.extbankbranch_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_ext_bank_branch_rec.branch_party_id := p2_a0;
    ddp_ext_bank_branch_rec.bank_party_id := p2_a1;
    ddp_ext_bank_branch_rec.branch_name := p2_a2;
    ddp_ext_bank_branch_rec.branch_number := p2_a3;
    ddp_ext_bank_branch_rec.branch_type := p2_a4;
    ddp_ext_bank_branch_rec.alternate_branch_name := p2_a5;
    ddp_ext_bank_branch_rec.description := p2_a6;
    ddp_ext_bank_branch_rec.bic := p2_a7;
    ddp_ext_bank_branch_rec.eft_number := p2_a8;
    ddp_ext_bank_branch_rec.rfc_identifier := p2_a9;
    ddp_ext_bank_branch_rec.attribute_category := p2_a10;
    ddp_ext_bank_branch_rec.attribute1 := p2_a11;
    ddp_ext_bank_branch_rec.attribute2 := p2_a12;
    ddp_ext_bank_branch_rec.attribute3 := p2_a13;
    ddp_ext_bank_branch_rec.attribute4 := p2_a14;
    ddp_ext_bank_branch_rec.attribute5 := p2_a15;
    ddp_ext_bank_branch_rec.attribute6 := p2_a16;
    ddp_ext_bank_branch_rec.attribute7 := p2_a17;
    ddp_ext_bank_branch_rec.attribute8 := p2_a18;
    ddp_ext_bank_branch_rec.attribute9 := p2_a19;
    ddp_ext_bank_branch_rec.attribute10 := p2_a20;
    ddp_ext_bank_branch_rec.attribute11 := p2_a21;
    ddp_ext_bank_branch_rec.attribute12 := p2_a22;
    ddp_ext_bank_branch_rec.attribute13 := p2_a23;
    ddp_ext_bank_branch_rec.attribute14 := p2_a24;
    ddp_ext_bank_branch_rec.attribute15 := p2_a25;
    ddp_ext_bank_branch_rec.attribute16 := p2_a26;
    ddp_ext_bank_branch_rec.attribute17 := p2_a27;
    ddp_ext_bank_branch_rec.attribute18 := p2_a28;
    ddp_ext_bank_branch_rec.attribute19 := p2_a29;
    ddp_ext_bank_branch_rec.attribute20 := p2_a30;
    ddp_ext_bank_branch_rec.attribute21 := p2_a31;
    ddp_ext_bank_branch_rec.attribute22 := p2_a32;
    ddp_ext_bank_branch_rec.attribute23 := p2_a33;
    ddp_ext_bank_branch_rec.attribute24 := p2_a34;
    ddp_ext_bank_branch_rec.bch_object_version_number := p2_a35;
    ddp_ext_bank_branch_rec.typ_object_version_number := p2_a36;
    ddp_ext_bank_branch_rec.rfc_object_version_number := p2_a37;
    ddp_ext_bank_branch_rec.eft_object_version_number := p2_a38;





    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.update_ext_bank_branch(p_api_version,
      p_init_msg_list,
      ddp_ext_bank_branch_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddp_ext_bank_branch_rec.branch_party_id;
    p2_a1 := ddp_ext_bank_branch_rec.bank_party_id;
    p2_a2 := ddp_ext_bank_branch_rec.branch_name;
    p2_a3 := ddp_ext_bank_branch_rec.branch_number;
    p2_a4 := ddp_ext_bank_branch_rec.branch_type;
    p2_a5 := ddp_ext_bank_branch_rec.alternate_branch_name;
    p2_a6 := ddp_ext_bank_branch_rec.description;
    p2_a7 := ddp_ext_bank_branch_rec.bic;
    p2_a8 := ddp_ext_bank_branch_rec.eft_number;
    p2_a9 := ddp_ext_bank_branch_rec.rfc_identifier;
    p2_a10 := ddp_ext_bank_branch_rec.attribute_category;
    p2_a11 := ddp_ext_bank_branch_rec.attribute1;
    p2_a12 := ddp_ext_bank_branch_rec.attribute2;
    p2_a13 := ddp_ext_bank_branch_rec.attribute3;
    p2_a14 := ddp_ext_bank_branch_rec.attribute4;
    p2_a15 := ddp_ext_bank_branch_rec.attribute5;
    p2_a16 := ddp_ext_bank_branch_rec.attribute6;
    p2_a17 := ddp_ext_bank_branch_rec.attribute7;
    p2_a18 := ddp_ext_bank_branch_rec.attribute8;
    p2_a19 := ddp_ext_bank_branch_rec.attribute9;
    p2_a20 := ddp_ext_bank_branch_rec.attribute10;
    p2_a21 := ddp_ext_bank_branch_rec.attribute11;
    p2_a22 := ddp_ext_bank_branch_rec.attribute12;
    p2_a23 := ddp_ext_bank_branch_rec.attribute13;
    p2_a24 := ddp_ext_bank_branch_rec.attribute14;
    p2_a25 := ddp_ext_bank_branch_rec.attribute15;
    p2_a26 := ddp_ext_bank_branch_rec.attribute16;
    p2_a27 := ddp_ext_bank_branch_rec.attribute17;
    p2_a28 := ddp_ext_bank_branch_rec.attribute18;
    p2_a29 := ddp_ext_bank_branch_rec.attribute19;
    p2_a30 := ddp_ext_bank_branch_rec.attribute20;
    p2_a31 := ddp_ext_bank_branch_rec.attribute21;
    p2_a32 := ddp_ext_bank_branch_rec.attribute22;
    p2_a33 := ddp_ext_bank_branch_rec.attribute23;
    p2_a34 := ddp_ext_bank_branch_rec.attribute24;
    p2_a35 := ddp_ext_bank_branch_rec.bch_object_version_number;
    p2_a36 := ddp_ext_bank_branch_rec.typ_object_version_number;
    p2_a37 := ddp_ext_bank_branch_rec.rfc_object_version_number;
    p2_a38 := ddp_ext_bank_branch_rec.eft_object_version_number;




    p6_a0 := ddx_response.result_code;
    p6_a1 := ddx_response.result_category;
    p6_a2 := ddx_response.result_message;
  end;

  procedure set_ext_bank_branch_end_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_branch_id  NUMBER
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  )

  as
    ddp_end_date date;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);





    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.set_ext_bank_branch_end_date(p_api_version,
      p_init_msg_list,
      p_branch_id,
      ddp_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_response.result_code;
    p7_a1 := ddx_response.result_category;
    p7_a2 := ddx_response.result_message;
  end;

  procedure check_ext_bank_branch_exist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_id  NUMBER
    , p_branch_name  VARCHAR2
    , p_branch_number  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_branch_id out nocopy  NUMBER
    , x_end_date out nocopy  DATE
    , p10_a0 out nocopy  VARCHAR2
    , p10_a1 out nocopy  VARCHAR2
    , p10_a2 out nocopy  VARCHAR2
  )

  as
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.check_ext_bank_branch_exist(p_api_version,
      p_init_msg_list,
      p_bank_id,
      p_branch_name,
      p_branch_number,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_branch_id,
      x_end_date,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := ddx_response.result_code;
    p10_a1 := ddx_response.result_category;
    p10_a2 := ddx_response.result_message;
  end;

  procedure create_ext_bank_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  NUMBER
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  DATE
    , p2_a24  DATE
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  NUMBER
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , x_acct_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  )

  as
    ddp_ext_bank_acct_rec iby_ext_bankacct_pub.extbankacct_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_ext_bank_acct_rec.bank_account_id := p2_a0;
    ddp_ext_bank_acct_rec.country_code := p2_a1;
    ddp_ext_bank_acct_rec.branch_id := p2_a2;
    ddp_ext_bank_acct_rec.bank_id := p2_a3;
    ddp_ext_bank_acct_rec.acct_owner_party_id := p2_a4;
    ddp_ext_bank_acct_rec.bank_account_name := p2_a5;
    ddp_ext_bank_acct_rec.bank_account_num := p2_a6;
    ddp_ext_bank_acct_rec.currency := p2_a7;
    ddp_ext_bank_acct_rec.iban := p2_a8;
    ddp_ext_bank_acct_rec.check_digits := p2_a9;
    ddp_ext_bank_acct_rec.multi_currency_allowed_flag := p2_a10;
    ddp_ext_bank_acct_rec.alternate_acct_name := p2_a11;
    ddp_ext_bank_acct_rec.short_acct_name := p2_a12;
    ddp_ext_bank_acct_rec.acct_type := p2_a13;
    ddp_ext_bank_acct_rec.acct_suffix := p2_a14;
    ddp_ext_bank_acct_rec.description := p2_a15;
    ddp_ext_bank_acct_rec.agency_location_code := p2_a16;
    ddp_ext_bank_acct_rec.foreign_payment_use_flag := p2_a17;
    ddp_ext_bank_acct_rec.exchange_rate_agreement_num := p2_a18;
    ddp_ext_bank_acct_rec.exchange_rate_agreement_type := p2_a19;
    ddp_ext_bank_acct_rec.exchange_rate := p2_a20;
    ddp_ext_bank_acct_rec.payment_factor_flag := p2_a21;
    ddp_ext_bank_acct_rec.status := p2_a22;
    ddp_ext_bank_acct_rec.end_date := rosetta_g_miss_date_in_map(p2_a23);
    ddp_ext_bank_acct_rec.start_date := rosetta_g_miss_date_in_map(p2_a24);
    ddp_ext_bank_acct_rec.hedging_contract_reference := p2_a25;
    ddp_ext_bank_acct_rec.attribute_category := p2_a26;
    ddp_ext_bank_acct_rec.attribute1 := p2_a27;
    ddp_ext_bank_acct_rec.attribute2 := p2_a28;
    ddp_ext_bank_acct_rec.attribute3 := p2_a29;
    ddp_ext_bank_acct_rec.attribute4 := p2_a30;
    ddp_ext_bank_acct_rec.attribute5 := p2_a31;
    ddp_ext_bank_acct_rec.attribute6 := p2_a32;
    ddp_ext_bank_acct_rec.attribute7 := p2_a33;
    ddp_ext_bank_acct_rec.attribute8 := p2_a34;
    ddp_ext_bank_acct_rec.attribute9 := p2_a35;
    ddp_ext_bank_acct_rec.attribute10 := p2_a36;
    ddp_ext_bank_acct_rec.attribute11 := p2_a37;
    ddp_ext_bank_acct_rec.attribute12 := p2_a38;
    ddp_ext_bank_acct_rec.attribute13 := p2_a39;
    ddp_ext_bank_acct_rec.attribute14 := p2_a40;
    ddp_ext_bank_acct_rec.attribute15 := p2_a41;
    ddp_ext_bank_acct_rec.object_version_number := p2_a42;
    ddp_ext_bank_acct_rec.secondary_account_reference := p2_a43;
    ddp_ext_bank_acct_rec.contact_name := p2_a44;
    ddp_ext_bank_acct_rec.contact_phone := p2_a45;
    ddp_ext_bank_acct_rec.contact_email := p2_a46;
    ddp_ext_bank_acct_rec.contact_fax := p2_a47;






    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.create_ext_bank_acct(p_api_version,
      p_init_msg_list,
      ddp_ext_bank_acct_rec,
      x_acct_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_response.result_code;
    p7_a1 := ddx_response.result_category;
    p7_a2 := ddx_response.result_message;
  end;

  procedure create_ext_bank_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  NUMBER
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  DATE
    , p2_a24  DATE
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  NUMBER
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p_association_level  VARCHAR2
    , p_supplier_site_id  NUMBER
    , p_party_site_id  NUMBER
    , p_org_id  NUMBER
    , p_org_type  VARCHAR2
    , x_acct_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0 out nocopy  VARCHAR2
    , p12_a1 out nocopy  VARCHAR2
    , p12_a2 out nocopy  VARCHAR2
  )

  as
    ddp_ext_bank_acct_rec iby_ext_bankacct_pub.extbankacct_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_ext_bank_acct_rec.bank_account_id := p2_a0;
    ddp_ext_bank_acct_rec.country_code := p2_a1;
    ddp_ext_bank_acct_rec.branch_id := p2_a2;
    ddp_ext_bank_acct_rec.bank_id := p2_a3;
    ddp_ext_bank_acct_rec.acct_owner_party_id := p2_a4;
    ddp_ext_bank_acct_rec.bank_account_name := p2_a5;
    ddp_ext_bank_acct_rec.bank_account_num := p2_a6;
    ddp_ext_bank_acct_rec.currency := p2_a7;
    ddp_ext_bank_acct_rec.iban := p2_a8;
    ddp_ext_bank_acct_rec.check_digits := p2_a9;
    ddp_ext_bank_acct_rec.multi_currency_allowed_flag := p2_a10;
    ddp_ext_bank_acct_rec.alternate_acct_name := p2_a11;
    ddp_ext_bank_acct_rec.short_acct_name := p2_a12;
    ddp_ext_bank_acct_rec.acct_type := p2_a13;
    ddp_ext_bank_acct_rec.acct_suffix := p2_a14;
    ddp_ext_bank_acct_rec.description := p2_a15;
    ddp_ext_bank_acct_rec.agency_location_code := p2_a16;
    ddp_ext_bank_acct_rec.foreign_payment_use_flag := p2_a17;
    ddp_ext_bank_acct_rec.exchange_rate_agreement_num := p2_a18;
    ddp_ext_bank_acct_rec.exchange_rate_agreement_type := p2_a19;
    ddp_ext_bank_acct_rec.exchange_rate := p2_a20;
    ddp_ext_bank_acct_rec.payment_factor_flag := p2_a21;
    ddp_ext_bank_acct_rec.status := p2_a22;
    ddp_ext_bank_acct_rec.end_date := rosetta_g_miss_date_in_map(p2_a23);
    ddp_ext_bank_acct_rec.start_date := rosetta_g_miss_date_in_map(p2_a24);
    ddp_ext_bank_acct_rec.hedging_contract_reference := p2_a25;
    ddp_ext_bank_acct_rec.attribute_category := p2_a26;
    ddp_ext_bank_acct_rec.attribute1 := p2_a27;
    ddp_ext_bank_acct_rec.attribute2 := p2_a28;
    ddp_ext_bank_acct_rec.attribute3 := p2_a29;
    ddp_ext_bank_acct_rec.attribute4 := p2_a30;
    ddp_ext_bank_acct_rec.attribute5 := p2_a31;
    ddp_ext_bank_acct_rec.attribute6 := p2_a32;
    ddp_ext_bank_acct_rec.attribute7 := p2_a33;
    ddp_ext_bank_acct_rec.attribute8 := p2_a34;
    ddp_ext_bank_acct_rec.attribute9 := p2_a35;
    ddp_ext_bank_acct_rec.attribute10 := p2_a36;
    ddp_ext_bank_acct_rec.attribute11 := p2_a37;
    ddp_ext_bank_acct_rec.attribute12 := p2_a38;
    ddp_ext_bank_acct_rec.attribute13 := p2_a39;
    ddp_ext_bank_acct_rec.attribute14 := p2_a40;
    ddp_ext_bank_acct_rec.attribute15 := p2_a41;
    ddp_ext_bank_acct_rec.object_version_number := p2_a42;
    ddp_ext_bank_acct_rec.secondary_account_reference := p2_a43;
    ddp_ext_bank_acct_rec.contact_name := p2_a44;
    ddp_ext_bank_acct_rec.contact_phone := p2_a45;
    ddp_ext_bank_acct_rec.contact_email := p2_a46;
    ddp_ext_bank_acct_rec.contact_fax := p2_a47;











    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.create_ext_bank_acct(p_api_version,
      p_init_msg_list,
      ddp_ext_bank_acct_rec,
      p_association_level,
      p_supplier_site_id,
      p_party_site_id,
      p_org_id,
      p_org_type,
      x_acct_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    p12_a0 := ddx_response.result_code;
    p12_a1 := ddx_response.result_category;
    p12_a2 := ddx_response.result_message;
  end;

  procedure update_ext_bank_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 in out nocopy  NUMBER
    , p2_a1 in out nocopy  VARCHAR2
    , p2_a2 in out nocopy  NUMBER
    , p2_a3 in out nocopy  NUMBER
    , p2_a4 in out nocopy  NUMBER
    , p2_a5 in out nocopy  VARCHAR2
    , p2_a6 in out nocopy  VARCHAR2
    , p2_a7 in out nocopy  VARCHAR2
    , p2_a8 in out nocopy  VARCHAR2
    , p2_a9 in out nocopy  VARCHAR2
    , p2_a10 in out nocopy  VARCHAR2
    , p2_a11 in out nocopy  VARCHAR2
    , p2_a12 in out nocopy  VARCHAR2
    , p2_a13 in out nocopy  VARCHAR2
    , p2_a14 in out nocopy  VARCHAR2
    , p2_a15 in out nocopy  VARCHAR2
    , p2_a16 in out nocopy  VARCHAR2
    , p2_a17 in out nocopy  VARCHAR2
    , p2_a18 in out nocopy  VARCHAR2
    , p2_a19 in out nocopy  VARCHAR2
    , p2_a20 in out nocopy  NUMBER
    , p2_a21 in out nocopy  VARCHAR2
    , p2_a22 in out nocopy  VARCHAR2
    , p2_a23 in out nocopy  DATE
    , p2_a24 in out nocopy  DATE
    , p2_a25 in out nocopy  VARCHAR2
    , p2_a26 in out nocopy  VARCHAR2
    , p2_a27 in out nocopy  VARCHAR2
    , p2_a28 in out nocopy  VARCHAR2
    , p2_a29 in out nocopy  VARCHAR2
    , p2_a30 in out nocopy  VARCHAR2
    , p2_a31 in out nocopy  VARCHAR2
    , p2_a32 in out nocopy  VARCHAR2
    , p2_a33 in out nocopy  VARCHAR2
    , p2_a34 in out nocopy  VARCHAR2
    , p2_a35 in out nocopy  VARCHAR2
    , p2_a36 in out nocopy  VARCHAR2
    , p2_a37 in out nocopy  VARCHAR2
    , p2_a38 in out nocopy  VARCHAR2
    , p2_a39 in out nocopy  VARCHAR2
    , p2_a40 in out nocopy  VARCHAR2
    , p2_a41 in out nocopy  VARCHAR2
    , p2_a42 in out nocopy  NUMBER
    , p2_a43 in out nocopy  VARCHAR2
    , p2_a44 in out nocopy  VARCHAR2
    , p2_a45 in out nocopy  VARCHAR2
    , p2_a46 in out nocopy  VARCHAR2
    , p2_a47 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
  )

  as
    ddp_ext_bank_acct_rec iby_ext_bankacct_pub.extbankacct_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_ext_bank_acct_rec.bank_account_id := p2_a0;
    ddp_ext_bank_acct_rec.country_code := p2_a1;
    ddp_ext_bank_acct_rec.branch_id := p2_a2;
    ddp_ext_bank_acct_rec.bank_id := p2_a3;
    ddp_ext_bank_acct_rec.acct_owner_party_id := p2_a4;
    ddp_ext_bank_acct_rec.bank_account_name := p2_a5;
    ddp_ext_bank_acct_rec.bank_account_num := p2_a6;
    ddp_ext_bank_acct_rec.currency := p2_a7;
    ddp_ext_bank_acct_rec.iban := p2_a8;
    ddp_ext_bank_acct_rec.check_digits := p2_a9;
    ddp_ext_bank_acct_rec.multi_currency_allowed_flag := p2_a10;
    ddp_ext_bank_acct_rec.alternate_acct_name := p2_a11;
    ddp_ext_bank_acct_rec.short_acct_name := p2_a12;
    ddp_ext_bank_acct_rec.acct_type := p2_a13;
    ddp_ext_bank_acct_rec.acct_suffix := p2_a14;
    ddp_ext_bank_acct_rec.description := p2_a15;
    ddp_ext_bank_acct_rec.agency_location_code := p2_a16;
    ddp_ext_bank_acct_rec.foreign_payment_use_flag := p2_a17;
    ddp_ext_bank_acct_rec.exchange_rate_agreement_num := p2_a18;
    ddp_ext_bank_acct_rec.exchange_rate_agreement_type := p2_a19;
    ddp_ext_bank_acct_rec.exchange_rate := p2_a20;
    ddp_ext_bank_acct_rec.payment_factor_flag := p2_a21;
    ddp_ext_bank_acct_rec.status := p2_a22;
    ddp_ext_bank_acct_rec.end_date := rosetta_g_miss_date_in_map(p2_a23);
    ddp_ext_bank_acct_rec.start_date := rosetta_g_miss_date_in_map(p2_a24);
    ddp_ext_bank_acct_rec.hedging_contract_reference := p2_a25;
    ddp_ext_bank_acct_rec.attribute_category := p2_a26;
    ddp_ext_bank_acct_rec.attribute1 := p2_a27;
    ddp_ext_bank_acct_rec.attribute2 := p2_a28;
    ddp_ext_bank_acct_rec.attribute3 := p2_a29;
    ddp_ext_bank_acct_rec.attribute4 := p2_a30;
    ddp_ext_bank_acct_rec.attribute5 := p2_a31;
    ddp_ext_bank_acct_rec.attribute6 := p2_a32;
    ddp_ext_bank_acct_rec.attribute7 := p2_a33;
    ddp_ext_bank_acct_rec.attribute8 := p2_a34;
    ddp_ext_bank_acct_rec.attribute9 := p2_a35;
    ddp_ext_bank_acct_rec.attribute10 := p2_a36;
    ddp_ext_bank_acct_rec.attribute11 := p2_a37;
    ddp_ext_bank_acct_rec.attribute12 := p2_a38;
    ddp_ext_bank_acct_rec.attribute13 := p2_a39;
    ddp_ext_bank_acct_rec.attribute14 := p2_a40;
    ddp_ext_bank_acct_rec.attribute15 := p2_a41;
    ddp_ext_bank_acct_rec.object_version_number := p2_a42;
    ddp_ext_bank_acct_rec.secondary_account_reference := p2_a43;
    ddp_ext_bank_acct_rec.contact_name := p2_a44;
    ddp_ext_bank_acct_rec.contact_phone := p2_a45;
    ddp_ext_bank_acct_rec.contact_email := p2_a46;
    ddp_ext_bank_acct_rec.contact_fax := p2_a47;





    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.update_ext_bank_acct(p_api_version,
      p_init_msg_list,
      ddp_ext_bank_acct_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddp_ext_bank_acct_rec.bank_account_id;
    p2_a1 := ddp_ext_bank_acct_rec.country_code;
    p2_a2 := ddp_ext_bank_acct_rec.branch_id;
    p2_a3 := ddp_ext_bank_acct_rec.bank_id;
    p2_a4 := ddp_ext_bank_acct_rec.acct_owner_party_id;
    p2_a5 := ddp_ext_bank_acct_rec.bank_account_name;
    p2_a6 := ddp_ext_bank_acct_rec.bank_account_num;
    p2_a7 := ddp_ext_bank_acct_rec.currency;
    p2_a8 := ddp_ext_bank_acct_rec.iban;
    p2_a9 := ddp_ext_bank_acct_rec.check_digits;
    p2_a10 := ddp_ext_bank_acct_rec.multi_currency_allowed_flag;
    p2_a11 := ddp_ext_bank_acct_rec.alternate_acct_name;
    p2_a12 := ddp_ext_bank_acct_rec.short_acct_name;
    p2_a13 := ddp_ext_bank_acct_rec.acct_type;
    p2_a14 := ddp_ext_bank_acct_rec.acct_suffix;
    p2_a15 := ddp_ext_bank_acct_rec.description;
    p2_a16 := ddp_ext_bank_acct_rec.agency_location_code;
    p2_a17 := ddp_ext_bank_acct_rec.foreign_payment_use_flag;
    p2_a18 := ddp_ext_bank_acct_rec.exchange_rate_agreement_num;
    p2_a19 := ddp_ext_bank_acct_rec.exchange_rate_agreement_type;
    p2_a20 := ddp_ext_bank_acct_rec.exchange_rate;
    p2_a21 := ddp_ext_bank_acct_rec.payment_factor_flag;
    p2_a22 := ddp_ext_bank_acct_rec.status;
    p2_a23 := ddp_ext_bank_acct_rec.end_date;
    p2_a24 := ddp_ext_bank_acct_rec.start_date;
    p2_a25 := ddp_ext_bank_acct_rec.hedging_contract_reference;
    p2_a26 := ddp_ext_bank_acct_rec.attribute_category;
    p2_a27 := ddp_ext_bank_acct_rec.attribute1;
    p2_a28 := ddp_ext_bank_acct_rec.attribute2;
    p2_a29 := ddp_ext_bank_acct_rec.attribute3;
    p2_a30 := ddp_ext_bank_acct_rec.attribute4;
    p2_a31 := ddp_ext_bank_acct_rec.attribute5;
    p2_a32 := ddp_ext_bank_acct_rec.attribute6;
    p2_a33 := ddp_ext_bank_acct_rec.attribute7;
    p2_a34 := ddp_ext_bank_acct_rec.attribute8;
    p2_a35 := ddp_ext_bank_acct_rec.attribute9;
    p2_a36 := ddp_ext_bank_acct_rec.attribute10;
    p2_a37 := ddp_ext_bank_acct_rec.attribute11;
    p2_a38 := ddp_ext_bank_acct_rec.attribute12;
    p2_a39 := ddp_ext_bank_acct_rec.attribute13;
    p2_a40 := ddp_ext_bank_acct_rec.attribute14;
    p2_a41 := ddp_ext_bank_acct_rec.attribute15;
    p2_a42 := ddp_ext_bank_acct_rec.object_version_number;
    p2_a43 := ddp_ext_bank_acct_rec.secondary_account_reference;
    p2_a44 := ddp_ext_bank_acct_rec.contact_name;
    p2_a45 := ddp_ext_bank_acct_rec.contact_phone;
    p2_a46 := ddp_ext_bank_acct_rec.contact_email;
    p2_a47 := ddp_ext_bank_acct_rec.contact_fax;




    p6_a0 := ddx_response.result_code;
    p6_a1 := ddx_response.result_category;
    p6_a2 := ddx_response.result_message;
  end;

  procedure get_ext_bank_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bankacct_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  DATE
    , p6_a24 out nocopy  DATE
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
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  )

  as
    ddx_bankacct iby_ext_bankacct_pub.extbankacct_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.get_ext_bank_acct(p_api_version,
      p_init_msg_list,
      p_bankacct_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_bankacct,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_bankacct.bank_account_id;
    p6_a1 := ddx_bankacct.country_code;
    p6_a2 := ddx_bankacct.branch_id;
    p6_a3 := ddx_bankacct.bank_id;
    p6_a4 := ddx_bankacct.acct_owner_party_id;
    p6_a5 := ddx_bankacct.bank_account_name;
    p6_a6 := ddx_bankacct.bank_account_num;
    p6_a7 := ddx_bankacct.currency;
    p6_a8 := ddx_bankacct.iban;
    p6_a9 := ddx_bankacct.check_digits;
    p6_a10 := ddx_bankacct.multi_currency_allowed_flag;
    p6_a11 := ddx_bankacct.alternate_acct_name;
    p6_a12 := ddx_bankacct.short_acct_name;
    p6_a13 := ddx_bankacct.acct_type;
    p6_a14 := ddx_bankacct.acct_suffix;
    p6_a15 := ddx_bankacct.description;
    p6_a16 := ddx_bankacct.agency_location_code;
    p6_a17 := ddx_bankacct.foreign_payment_use_flag;
    p6_a18 := ddx_bankacct.exchange_rate_agreement_num;
    p6_a19 := ddx_bankacct.exchange_rate_agreement_type;
    p6_a20 := ddx_bankacct.exchange_rate;
    p6_a21 := ddx_bankacct.payment_factor_flag;
    p6_a22 := ddx_bankacct.status;
    p6_a23 := ddx_bankacct.end_date;
    p6_a24 := ddx_bankacct.start_date;
    p6_a25 := ddx_bankacct.hedging_contract_reference;
    p6_a26 := ddx_bankacct.attribute_category;
    p6_a27 := ddx_bankacct.attribute1;
    p6_a28 := ddx_bankacct.attribute2;
    p6_a29 := ddx_bankacct.attribute3;
    p6_a30 := ddx_bankacct.attribute4;
    p6_a31 := ddx_bankacct.attribute5;
    p6_a32 := ddx_bankacct.attribute6;
    p6_a33 := ddx_bankacct.attribute7;
    p6_a34 := ddx_bankacct.attribute8;
    p6_a35 := ddx_bankacct.attribute9;
    p6_a36 := ddx_bankacct.attribute10;
    p6_a37 := ddx_bankacct.attribute11;
    p6_a38 := ddx_bankacct.attribute12;
    p6_a39 := ddx_bankacct.attribute13;
    p6_a40 := ddx_bankacct.attribute14;
    p6_a41 := ddx_bankacct.attribute15;
    p6_a42 := ddx_bankacct.object_version_number;
    p6_a43 := ddx_bankacct.secondary_account_reference;
    p6_a44 := ddx_bankacct.contact_name;
    p6_a45 := ddx_bankacct.contact_phone;
    p6_a46 := ddx_bankacct.contact_email;
    p6_a47 := ddx_bankacct.contact_fax;

    p7_a0 := ddx_response.result_code;
    p7_a1 := ddx_response.result_category;
    p7_a2 := ddx_response.result_message;
  end;

  procedure get_ext_bank_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bankacct_id  NUMBER
    , p_sec_key  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  NUMBER
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  VARCHAR2
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  VARCHAR2
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  NUMBER
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  DATE
    , p7_a24 out nocopy  DATE
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
    , p7_a39 out nocopy  VARCHAR2
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  NUMBER
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  VARCHAR2
    , p7_a46 out nocopy  VARCHAR2
    , p7_a47 out nocopy  VARCHAR2
    , p8_a0 out nocopy  VARCHAR2
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  VARCHAR2
  )

  as
    ddx_bankacct iby_ext_bankacct_pub.extbankacct_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.get_ext_bank_acct(p_api_version,
      p_init_msg_list,
      p_bankacct_id,
      p_sec_key,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_bankacct,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_bankacct.bank_account_id;
    p7_a1 := ddx_bankacct.country_code;
    p7_a2 := ddx_bankacct.branch_id;
    p7_a3 := ddx_bankacct.bank_id;
    p7_a4 := ddx_bankacct.acct_owner_party_id;
    p7_a5 := ddx_bankacct.bank_account_name;
    p7_a6 := ddx_bankacct.bank_account_num;
    p7_a7 := ddx_bankacct.currency;
    p7_a8 := ddx_bankacct.iban;
    p7_a9 := ddx_bankacct.check_digits;
    p7_a10 := ddx_bankacct.multi_currency_allowed_flag;
    p7_a11 := ddx_bankacct.alternate_acct_name;
    p7_a12 := ddx_bankacct.short_acct_name;
    p7_a13 := ddx_bankacct.acct_type;
    p7_a14 := ddx_bankacct.acct_suffix;
    p7_a15 := ddx_bankacct.description;
    p7_a16 := ddx_bankacct.agency_location_code;
    p7_a17 := ddx_bankacct.foreign_payment_use_flag;
    p7_a18 := ddx_bankacct.exchange_rate_agreement_num;
    p7_a19 := ddx_bankacct.exchange_rate_agreement_type;
    p7_a20 := ddx_bankacct.exchange_rate;
    p7_a21 := ddx_bankacct.payment_factor_flag;
    p7_a22 := ddx_bankacct.status;
    p7_a23 := ddx_bankacct.end_date;
    p7_a24 := ddx_bankacct.start_date;
    p7_a25 := ddx_bankacct.hedging_contract_reference;
    p7_a26 := ddx_bankacct.attribute_category;
    p7_a27 := ddx_bankacct.attribute1;
    p7_a28 := ddx_bankacct.attribute2;
    p7_a29 := ddx_bankacct.attribute3;
    p7_a30 := ddx_bankacct.attribute4;
    p7_a31 := ddx_bankacct.attribute5;
    p7_a32 := ddx_bankacct.attribute6;
    p7_a33 := ddx_bankacct.attribute7;
    p7_a34 := ddx_bankacct.attribute8;
    p7_a35 := ddx_bankacct.attribute9;
    p7_a36 := ddx_bankacct.attribute10;
    p7_a37 := ddx_bankacct.attribute11;
    p7_a38 := ddx_bankacct.attribute12;
    p7_a39 := ddx_bankacct.attribute13;
    p7_a40 := ddx_bankacct.attribute14;
    p7_a41 := ddx_bankacct.attribute15;
    p7_a42 := ddx_bankacct.object_version_number;
    p7_a43 := ddx_bankacct.secondary_account_reference;
    p7_a44 := ddx_bankacct.contact_name;
    p7_a45 := ddx_bankacct.contact_phone;
    p7_a46 := ddx_bankacct.contact_email;
    p7_a47 := ddx_bankacct.contact_fax;

    p8_a0 := ddx_response.result_code;
    p8_a1 := ddx_response.result_category;
    p8_a2 := ddx_response.result_message;
  end;

  procedure set_ext_bank_acct_dates(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_acct_id  NUMBER
    , p_start_date  date
    , p_end_date  date
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);






    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.set_ext_bank_acct_dates(p_api_version,
      p_init_msg_list,
      p_acct_id,
      ddp_start_date,
      ddp_end_date,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddx_response.result_code;
    p9_a1 := ddx_response.result_category;
    p9_a2 := ddx_response.result_message;
  end;

  procedure check_ext_acct_exist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  VARCHAR2
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  NUMBER
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  DATE
    , p2_a24  DATE
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  NUMBER
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , x_acct_id out nocopy  NUMBER
    , x_start_date out nocopy  DATE
    , x_end_date out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy  VARCHAR2
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
  )

  as
    ddp_ext_bank_acct_rec iby_ext_bankacct_pub.extbankacct_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_ext_bank_acct_rec.bank_account_id := p2_a0;
    ddp_ext_bank_acct_rec.country_code := p2_a1;
    ddp_ext_bank_acct_rec.branch_id := p2_a2;
    ddp_ext_bank_acct_rec.bank_id := p2_a3;
    ddp_ext_bank_acct_rec.acct_owner_party_id := p2_a4;
    ddp_ext_bank_acct_rec.bank_account_name := p2_a5;
    ddp_ext_bank_acct_rec.bank_account_num := p2_a6;
    ddp_ext_bank_acct_rec.currency := p2_a7;
    ddp_ext_bank_acct_rec.iban := p2_a8;
    ddp_ext_bank_acct_rec.check_digits := p2_a9;
    ddp_ext_bank_acct_rec.multi_currency_allowed_flag := p2_a10;
    ddp_ext_bank_acct_rec.alternate_acct_name := p2_a11;
    ddp_ext_bank_acct_rec.short_acct_name := p2_a12;
    ddp_ext_bank_acct_rec.acct_type := p2_a13;
    ddp_ext_bank_acct_rec.acct_suffix := p2_a14;
    ddp_ext_bank_acct_rec.description := p2_a15;
    ddp_ext_bank_acct_rec.agency_location_code := p2_a16;
    ddp_ext_bank_acct_rec.foreign_payment_use_flag := p2_a17;
    ddp_ext_bank_acct_rec.exchange_rate_agreement_num := p2_a18;
    ddp_ext_bank_acct_rec.exchange_rate_agreement_type := p2_a19;
    ddp_ext_bank_acct_rec.exchange_rate := p2_a20;
    ddp_ext_bank_acct_rec.payment_factor_flag := p2_a21;
    ddp_ext_bank_acct_rec.status := p2_a22;
    ddp_ext_bank_acct_rec.end_date := rosetta_g_miss_date_in_map(p2_a23);
    ddp_ext_bank_acct_rec.start_date := rosetta_g_miss_date_in_map(p2_a24);
    ddp_ext_bank_acct_rec.hedging_contract_reference := p2_a25;
    ddp_ext_bank_acct_rec.attribute_category := p2_a26;
    ddp_ext_bank_acct_rec.attribute1 := p2_a27;
    ddp_ext_bank_acct_rec.attribute2 := p2_a28;
    ddp_ext_bank_acct_rec.attribute3 := p2_a29;
    ddp_ext_bank_acct_rec.attribute4 := p2_a30;
    ddp_ext_bank_acct_rec.attribute5 := p2_a31;
    ddp_ext_bank_acct_rec.attribute6 := p2_a32;
    ddp_ext_bank_acct_rec.attribute7 := p2_a33;
    ddp_ext_bank_acct_rec.attribute8 := p2_a34;
    ddp_ext_bank_acct_rec.attribute9 := p2_a35;
    ddp_ext_bank_acct_rec.attribute10 := p2_a36;
    ddp_ext_bank_acct_rec.attribute11 := p2_a37;
    ddp_ext_bank_acct_rec.attribute12 := p2_a38;
    ddp_ext_bank_acct_rec.attribute13 := p2_a39;
    ddp_ext_bank_acct_rec.attribute14 := p2_a40;
    ddp_ext_bank_acct_rec.attribute15 := p2_a41;
    ddp_ext_bank_acct_rec.object_version_number := p2_a42;
    ddp_ext_bank_acct_rec.secondary_account_reference := p2_a43;
    ddp_ext_bank_acct_rec.contact_name := p2_a44;
    ddp_ext_bank_acct_rec.contact_phone := p2_a45;
    ddp_ext_bank_acct_rec.contact_email := p2_a46;
    ddp_ext_bank_acct_rec.contact_fax := p2_a47;








    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.check_ext_acct_exist(p_api_version,
      p_init_msg_list,
      ddp_ext_bank_acct_rec,
      x_acct_id,
      x_start_date,
      x_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := ddx_response.result_code;
    p9_a1 := ddx_response.result_category;
    p9_a2 := ddx_response.result_message;
  end;

  procedure check_ext_acct_exist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_id  VARCHAR2
    , p_branch_id  NUMBER
    , p_acct_number  VARCHAR2
    , p_acct_name  VARCHAR2
    , p_currency  VARCHAR2
    , p_country_code  VARCHAR2
    , x_acct_id out nocopy  NUMBER
    , x_start_date out nocopy  DATE
    , x_end_date out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p14_a0 out nocopy  VARCHAR2
    , p14_a1 out nocopy  VARCHAR2
    , p14_a2 out nocopy  VARCHAR2
  )

  as
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any















    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.check_ext_acct_exist(p_api_version,
      p_init_msg_list,
      p_bank_id,
      p_branch_id,
      p_acct_number,
      p_acct_name,
      p_currency,
      p_country_code,
      x_acct_id,
      x_start_date,
      x_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














    p14_a0 := ddx_response.result_code;
    p14_a1 := ddx_response.result_category;
    p14_a2 := ddx_response.result_message;
  end;

  procedure create_intermediary_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  NUMBER
    , x_intermediary_acct_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  )

  as
    ddp_intermed_acct_rec iby_ext_bankacct_pub.intermediaryacct_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_intermed_acct_rec.intermediary_acct_id := p2_a0;
    ddp_intermed_acct_rec.bank_account_id := p2_a1;
    ddp_intermed_acct_rec.country_code := p2_a2;
    ddp_intermed_acct_rec.bank_name := p2_a3;
    ddp_intermed_acct_rec.city := p2_a4;
    ddp_intermed_acct_rec.bank_code := p2_a5;
    ddp_intermed_acct_rec.branch_number := p2_a6;
    ddp_intermed_acct_rec.bic := p2_a7;
    ddp_intermed_acct_rec.account_number := p2_a8;
    ddp_intermed_acct_rec.check_digits := p2_a9;
    ddp_intermed_acct_rec.iban := p2_a10;
    ddp_intermed_acct_rec.comments := p2_a11;
    ddp_intermed_acct_rec.object_version_number := p2_a12;






    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.create_intermediary_acct(p_api_version,
      p_init_msg_list,
      ddp_intermed_acct_rec,
      x_intermediary_acct_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_response.result_code;
    p7_a1 := ddx_response.result_category;
    p7_a2 := ddx_response.result_message;
  end;

  procedure update_intermediary_acct(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 in out nocopy  NUMBER
    , p2_a1 in out nocopy  NUMBER
    , p2_a2 in out nocopy  VARCHAR2
    , p2_a3 in out nocopy  VARCHAR2
    , p2_a4 in out nocopy  VARCHAR2
    , p2_a5 in out nocopy  VARCHAR2
    , p2_a6 in out nocopy  VARCHAR2
    , p2_a7 in out nocopy  VARCHAR2
    , p2_a8 in out nocopy  VARCHAR2
    , p2_a9 in out nocopy  VARCHAR2
    , p2_a10 in out nocopy  VARCHAR2
    , p2_a11 in out nocopy  VARCHAR2
    , p2_a12 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
  )

  as
    ddp_intermed_acct_rec iby_ext_bankacct_pub.intermediaryacct_rec_type;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_intermed_acct_rec.intermediary_acct_id := p2_a0;
    ddp_intermed_acct_rec.bank_account_id := p2_a1;
    ddp_intermed_acct_rec.country_code := p2_a2;
    ddp_intermed_acct_rec.bank_name := p2_a3;
    ddp_intermed_acct_rec.city := p2_a4;
    ddp_intermed_acct_rec.bank_code := p2_a5;
    ddp_intermed_acct_rec.branch_number := p2_a6;
    ddp_intermed_acct_rec.bic := p2_a7;
    ddp_intermed_acct_rec.account_number := p2_a8;
    ddp_intermed_acct_rec.check_digits := p2_a9;
    ddp_intermed_acct_rec.iban := p2_a10;
    ddp_intermed_acct_rec.comments := p2_a11;
    ddp_intermed_acct_rec.object_version_number := p2_a12;





    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.update_intermediary_acct(p_api_version,
      p_init_msg_list,
      ddp_intermed_acct_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := ddp_intermed_acct_rec.intermediary_acct_id;
    p2_a1 := ddp_intermed_acct_rec.bank_account_id;
    p2_a2 := ddp_intermed_acct_rec.country_code;
    p2_a3 := ddp_intermed_acct_rec.bank_name;
    p2_a4 := ddp_intermed_acct_rec.city;
    p2_a5 := ddp_intermed_acct_rec.bank_code;
    p2_a6 := ddp_intermed_acct_rec.branch_number;
    p2_a7 := ddp_intermed_acct_rec.bic;
    p2_a8 := ddp_intermed_acct_rec.account_number;
    p2_a9 := ddp_intermed_acct_rec.check_digits;
    p2_a10 := ddp_intermed_acct_rec.iban;
    p2_a11 := ddp_intermed_acct_rec.comments;
    p2_a12 := ddp_intermed_acct_rec.object_version_number;




    p6_a0 := ddx_response.result_code;
    p6_a1 := ddx_response.result_category;
    p6_a2 := ddx_response.result_message;
  end;

  procedure add_joint_account_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_account_id  NUMBER
    , p_acct_owner_party_id  NUMBER
    , x_joint_acct_owner_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 out nocopy  VARCHAR2
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  VARCHAR2
  )

  as
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.add_joint_account_owner(p_api_version,
      p_init_msg_list,
      p_bank_account_id,
      p_acct_owner_party_id,
      x_joint_acct_owner_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_response.result_code;
    p8_a1 := ddx_response.result_category;
    p8_a2 := ddx_response.result_message;
  end;

  procedure set_joint_acct_owner_end_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_acct_owner_id  NUMBER
    , p_end_date  date
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0 out nocopy  VARCHAR2
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  VARCHAR2
  )

  as
    ddp_end_date date;
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);






    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.set_joint_acct_owner_end_date(p_api_version,
      p_init_msg_list,
      p_acct_owner_id,
      ddp_end_date,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_response.result_code;
    p8_a1 := ddx_response.result_category;
    p8_a2 := ddx_response.result_message;
  end;

  procedure change_primary_acct_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_acct_id  NUMBER
    , p_acct_owner_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  )

  as
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.change_primary_acct_owner(p_api_version,
      p_init_msg_list,
      p_bank_acct_id,
      p_acct_owner_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_response.result_code;
    p7_a1 := ddx_response.result_category;
    p7_a2 := ddx_response.result_message;
  end;

  procedure check_bank_acct_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_bank_acct_id  NUMBER
    , p_acct_owner_party_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy  VARCHAR2
    , p7_a1 out nocopy  VARCHAR2
    , p7_a2 out nocopy  VARCHAR2
  )

  as
    ddx_response iby_fndcpt_common_pub.result_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    iby_ext_bankacct_pub.check_bank_acct_owner(p_api_version,
      p_init_msg_list,
      p_bank_acct_id,
      p_acct_owner_party_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_response);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    p7_a0 := ddx_response.result_code;
    p7_a1 := ddx_response.result_category;
    p7_a2 := ddx_response.result_message;
  end;

end iby_ext_bankacct_pub_w;

/
